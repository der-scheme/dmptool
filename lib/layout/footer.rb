
require 'layout/tags/a'
require 'layout/tags/icon'

module Layout
  class Footer
    def initialize(config)
      @credits = Tags::Text.new(config[:credits])
      @icons = config[:icons].map {|iconfig| Tags::Icon.new(iconfig)}
      @links = config[:links].map {|lconfig| Tags::A.new(lconfig)}
    end

    attr_reader :credits

    def each_icon(&block)
      @icons.each(&block)
    end

    def each_link(&block)
      @links.each(&block)
    end
  end
end
