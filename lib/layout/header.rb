
##

module Layout

  ##
  # Provides an interface for operator-defined page headers.
  #
  # === Configuration ===
  # Configured by a Hash, supporting the following keys.
  # [:items]
  #     The navigation items. This can be any collection of
  #     Layout::Tags::NavItem configurations.

  class Header
    def initialize(config)
      @items = config[:navigation].map {|iconfig| Tags::NavItem.new(iconfig)}
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
