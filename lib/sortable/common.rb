
module Sortable
  module Common

    def namespace(child = nil)
      return @namespace unless child
      return :"#{@namespace}:#{child}" if @namespace
      child
    end

    ## Returns the namespaced order_scope.

    def order_scope(plain = false)
      return @order_scope if plain
      @namespaced_order_scope ||= namespace(@order_scope)
    end

  end
end
