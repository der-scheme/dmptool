
module Sortable
  module Controller

    ##
    # Declares an attribute sortable.
    #
    # The instance variable with the pluralized controller name (i.e.
    # "resource_contexts" in case of the ResourceContextsController) is treated
    # as the collection to be sorted and will be sorted if the attribute
    # matches the order scope, or if the ordering is marked as default (which
    # is triggered when the order_scope #param is blank).

    def sortable(attribute, _default = nil,
                 default: false, nested: nil,
                 inst_var: controller_name.pluralize,
                 model: controller_name.classify.constantize,
                 order_scope: :order_scope, namespace: nil)
      fail ArgumentError,
           'expected the 2nd parameter to be one of: :default, nil' unless
        _default.nil? || :default == _default

      default ||= _default
      order_scope = :"#{namespace}:order_scope" if namespace
      direction = namespace ? :"#{namespace}:direction" : :direction

      return unless (params[order_scope] && params[order_scope].to_sym == attribute) ||
                    (default && params[order_scope].blank?)

      attribute   = attribute.to_sym
      order_attr  = attribute
      @direction  ||= params[direction] =~ /desc/i ? 'desc' : 'asc'

      collection  = instance_variable_get("@#{inst_var}")

      if nested
        assoc, assocs = *model_association(model, attribute)
        collection = collection.joins(assoc)
        order_attr = "#{assocs}.#{nested}"
      end

      if block_given?
        collection = yield collection
      else
        collection = collection.order("#{order_attr} #{@direction}")
      end

      instance_variable_set("@#{inst_var}", collection)
      nil
    end

  end
end
