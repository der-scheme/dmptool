
##

class Layout

  ##
  # Provides an interface for operator-defined page headers.
  #
  # === Configuration ===
  # Configured by a Hash, supporting the following keys.
  # [:items]
  #     The navigation items. This can be any collection of
  #     Layout::Tags::NavItem configurations.

  class Header
    def initialize(context, config)
      @items = config[:navigation].lazy.map do |iconfig|
        Tags::NavItem.new(context, iconfig)
      end
    end

    ##
    # Iterates over each NavItem definition.
    #
    # If no block is given, an enumerator is returned instead.
    #
    # :yields: item

    def each_item(&block)
      @items.each(&block)
    end
  end
end
