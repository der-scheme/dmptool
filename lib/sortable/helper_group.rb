
require 'delegate'

module Sortable
  class HelperGroup < SimpleDelegator
    include Sortable::Common

    def initialize(helper: nil,
                   model: helper.class.controller_name.classify.constantize,
                   namespace: nil, order_scope: :order_scope)
      fail ArgumentError, 'expected model to be of type ActiveRecord::Base' if
        model && !model.respond_to?(:human_attribute_name)

      @helper = helper
      @model = model
      @namespace = namespace
      @order_scope = order_scope
      super(helper)
    end

    attr_reader :helper
    attr_reader :model

    def params
      @params ||= helper.filter_params
    end

    ## Creates a link that renders a column sortable with toggle effects.

    def sortable(column, title = nil)
      title ||= model.human_attribute_name(column) if model
      title ||= t(".#{column}", default: column.titleize)

      direction = namespace(:direction)

      # current asc and current desc classes are for supporting an eventual
      # arrow image or css class (not yet implemented) associated with the
      # sorting direction
      css_class = "current #{params[direction]}" if column == params[order_scope]
      dir = (column.to_s == params[order_scope] && params[direction] == 'asc') ? 'desc' : 'asc'
      helper.link_to title,
                     params.merge(order_scope => column, direction => dir),
                     {class: css_class}
    end

    ##
    # Executes _group_ in context of a HelperGroup specified by the parameters.

    def sortable_group(model: self.model, namespace: nil,
                       order_scope: self.order_scope, &group)
      HelperGroup.new(helper: helper, model: model,
                      namespace: self.namespace(namespace),
                      order_scope: order_scope)
          .instance_exec(&group)
    end

  end
end
