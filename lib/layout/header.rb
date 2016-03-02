
module Layout
  class Header
    def initialize(config)
      @items = config[:navigation].map {|iconfig| Tags::A.new(iconfig)}
    end

    def each_item(&block)
      @items.each(&block)
    end
  end
end
