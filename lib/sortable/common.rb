
module Sortable
  module Common

    ##
    # Returns a namespace String. If _child_ is not given, returns the current
    # namespace. If _child_ is given and the current namespace is defined,
    # returns _child_ scoped by the current namespace. Otherwise, returns child.

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
