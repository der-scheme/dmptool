
##

module Layout

  ##
  # Provides an interface for operator-defined footers, exposing the
  # credits/copyright statement, as well as footer links and social media icons
  # to configuration.
  #
  # === Configuration ===
  # Configured by a Hash, supporting the following keys.
  # [:credits]
  #     The block with the credits/copyright statement. This may be a String or
  #     a Proc, which, in the latter case, is executed during page render.
  # [:icons]
  #     The section with the social media icons. This can be any collection
  #     of Layout::Tags::Icon configurations.
  # [:links]
  #     The section with the links at the bottom of the page. This can be any
  #     collection of Layout::Tags::A configurations.

  class Footer
    def initialize(config)
      @credits = Tags::Text.new(config[:credits])
      @icons = config[:icons].map {|iconfig| Tags::Icon.new(iconfig)}
      @links = config[:links].map {|lconfig| Tags::A.new(lconfig)}
    end

    ##
    # Reader for the credits/copyright block at the bottom of the page.

    attr_reader :credits

    ##
    # Iterates over each Icon definition.
    #
    # If no block is given, an enumerator is returned instead
    #
    # :yields: icon

    def each_icon(&block)
      @icons.each(&block)
    end

    ##
    # Iterates over each Link definition.
    #
    # If no block is given, an enumerator is returned instead.
    #
    # :yields: link

    def each_link(&block)
      @links.each(&block)
    end
  end
end
