
module Sortable
  module Controller

    ##
    # Executes _group_ in context of a ControllerGroup specified by the
    # parameters.

    def sortable_group(inst_var: controller_name.pluralize,
                       model: controller_name.classify.constantize,
                       order_scope: :order_scope, namespace: nil,
                       &group)
      ControllerGroup.new(controller: self, inst_var: inst_var, model: model,
                          order_scope: order_scope, namespace: namespace)
          .instance_exec(&group)
    end

    ##
    # Declares an attribute sortable.
    #
    # The instance variable with the pluralized controller name (i.e.
    # "resource_contexts" in case of the ResourceContextsController) is treated
    # as the collection to be sorted and will be sorted if the attribute
    # matches the order scope, or if the ordering is marked as default (which
    # is triggered when the order_scope #param is blank).

    def sortable(attribute, _default = nil,
                 default: false, nested: nil, **options, &block)
      sortable_group(**options) do
        sortable(attribute, _default, default: default, nested: nested, &block)
      end
    end

  end
end
