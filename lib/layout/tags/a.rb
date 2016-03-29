
##

module Layout
  module Tags

    ##
    # Represents an HTML A tag.
    #
    # === Configuration ===
    # Configured by a Hash, supporting the following keys.
    # [:href]
    #     The link destination (href). This may be either a String with a
    #     literal URI or a Hash with +url_for+ options.
    # [:label]
    #     The link contents. This should be a hash with the keys +:key+ and
    #     +:fallback+, for I18n lookup as the key and the fallback options,
    #     respectively.
    # [:title]
    #     The contents of the link's title attribute. For configuration, see the
    #     _:label_ key.

    class A < Layout::Tags::Base
      include ActionDispatch::Routing
      include Rails.application.routes.url_helpers
      # Conditional include, depending on wether we have merged this with a
      # branch that supports route_i18n
      include RouteI18n::TranslationHelper if const_defined?(:RouteI18n)

      ##
      # Reader for the url options/href attribute.

      attr_reader :href

      ##
      # Reader for the label Hash responsible for I18n lookup of the link text.

      attr_reader :label

      ##
      # Reader for the title Hash responsible for I18n lookup of the title
      # attribute contents.

      attr_reader :title

      def initialize(config)
        @href, @label, @title = config.values_at(:href, :label, :title)
        super(config)
      end

      ##
      # Renders this Tag to a String, passing _attributes_ through to the HTML.
      #
      # :call-seq: to_s(**attributes)

      def to_s(label = nil, **attributes)
        if @href.is_a?(Hash) && self.class.const_defined?(:RouteI18n)
          # If @href is given as a parameter Hash for url_for and we have the
          # RouteI18n module, use the module's lookup functionality, ignoring
          # @label and @title.
          title = url_text_for(@href)
        else
          # Otherwise, do a regular I18n lookup for both the label and the
          # title, if they exist.
          label ||= I18n.t(@label[:key], default: @label[:fallback]) if @label
          title = I18n.t(@title[:key], default: @title[:fallback]) if @title
        end

        # Initialize whatever was left unitialized by the above code
        label ||= title
        title ||= label
        attributes[:title] ||= title

        # Finally do the render
        link_to label, @href, **attributes
      end
    end
  end
end
