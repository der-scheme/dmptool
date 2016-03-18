
module Layout
  class Header
    def initialize(config)
      @items = config[:navigation].map {|iconfig| Tags::NavItem.new(iconfig)}
    end

    def each_item(&block)
      @items.each(&block)
    end
  end
end
