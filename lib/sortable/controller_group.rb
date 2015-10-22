
require 'sortable/common'

module Sortable
  class ControllerGroup
    include Common

    def initialize(controller: nil,
                   inst_var: controller.class.controller_name.pluralize,
                   model: controller.class.controller_name.classify.constantize,
                   order_scope: :order_scope, namespace: nil)
      @controller = controller
      @inst_var = inst_var
      @model = model
      @order_scope = order_scope
      @namespace = namespace
    end

    attr_reader :controller
    attr_reader :inst_var
    attr_reader :model

    def collection
      controller.instance_variable_get("@#{inst_var}")
    end

    def collection=(new_collection)
      controller.instance_variable_set("@#{inst_var}", new_collection)
    end

    def params
      controller.params
    end

    ##
    # Declares an attribute sortable.
    #
    # The instance variable with the pluralized controller name (i.e.
    # "resource_contexts" in case of the ResourceContextsController) is treated
    # as the collection to be sorted and will be sorted if the attribute
    # matches the order scope, or if the ordering is marked as default (which
    # is triggered when the order_scope #param is blank).

    def sortable(attribute, _default = nil, default: false, nested: nil)
      fail ArgumentError,
           'expected the 2nd parameter to be one of: :default, nil' unless
        _default.nil? || :default == _default

      default ||= _default
      direction = namespace(:direction)

      return unless (params[order_scope] && params[order_scope].to_sym == attribute) ||
                    (default && params[order_scope].blank?)

      attribute   = attribute.to_sym
      order_attr  = attribute
      dir = params[direction] =~ /desc/i ? :desc : :asc
      # The following code is considered deprecated.
      controller.instance_variable_set("@direction", dir)

      if nested
        assoc, assocs = *model_association(attribute)
        self.collection &&= collection.joins(assoc)
        order_attr = "#{assocs}.#{nested}"
      end

      if block_given?
        self.collection &&= yield(collection, dir)
      else
        self.collection &&= collection.order("#{order_attr} #{dir}")
      end

      nil
    end

    def sortable_group(inst_var: self.inst_var, model: self.model,
                       order_scope: self.order_scope, namespace: nil,
                       &group)
      ControllerGroup.new(controller: controller, inst_var: inst_var,
                          model: model, order_scope: order_scope,
                          namespace: namespace)
          .instance_exec(&group)
    end

  private

    ##
    # Returns the associations name and plural_name, if an association can be
    # found for the given +model+ and +attribute+.

    def model_association(attribute)
      assoc = model.reflect_on_association(attribute.to_sym)
      assoc ||= model.reflect_on_all_associations.find do |association|
        case association.macro
        when :has_one
          association.options[:primary_key] &&
            association.options[:primary_key].to_sym == attribute.to_sym
        else
          association.options[:foreign_key] &&
            association.options[:foreign_key].to_sym == attribute.to_sym
        end
      end
      assoc ||= model.reflect_on_association(attribute.to_s.gsub(/_id\z/, '').to_sym)

      if assoc
        return assoc.name, assoc.options[:class_name].constantize.model_name.plural if
          assoc.options[:class_name]
        return assoc.name, assoc.plural_name
      end
    end

  end
end
