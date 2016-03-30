
module Sortable
  module Helper

    def sortable_group(model: controller_name.classify.constantize,
                       namespace: nil, order_scope: :order_scope,
                       &group)
      HelperGroup.new(helper: self, model: model, namespace: namespace,
                      order_scope: order_scope)
          .instance_exec(&group)
    end

    ## Creates a link that renders a column sortable with toggle effects.

    def sortable(column, title = nil, **options, &block)
      sortable_group(**options) {sortable(column, title, &block)}
    end

  end
end
