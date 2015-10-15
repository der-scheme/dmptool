
module Sortable
  module Helper

    ## Creates a link that renders a column sortable with toggle effects.

    def sortable(column, title = nil,
                 order_scope: :order_scope, namespace: nil,
                 model: controller_name.classify.constantize)
      fail ArgumentError, 'expected model to be of type ActiveRecord::Base' if
        model && !model.respond_to?(:human_attribute_name)

      order_scope = :"#{namespace}:order_scope" if namespace
      direction = namespace ? :"#{namespace}:direction" : :direction

      title ||= model.human_attribute_name(column) if model
      title ||= t(".#{column}", default: column.titleize)

      # current asc and current desc classes are for supporting an eventual
      # arrow image or css class (not yet implemented) associated with the
      # sorting direction
      css_class = "current #{params[direction]}" if column == params[order_scope]
      direction = (column.to_s == params[order_scope] && params[direction] == 'asc') ? 'desc' : 'asc'
      link_to title,
              filter_params.merge(order_scope => column, direction: direction),
              {class: css_class}
    end

  end
end
