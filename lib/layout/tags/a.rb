
##

class Layout
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

      def initialize(context, config)
        @href, @label, @target, @title =
          config.values_at(:href, :label, :target, :title)

        super
      end

      def attributes(params = {})
        attrs = {}
        attrs[:target] = @target.is_a?(Symbol) ? "_#{@target}" : @target
        super(attrs.merge(params))
      end

      ##
      # Renders this Tag to a String, passing _attributes_ through to the HTML.
      #
      # :call-seq: to_s(**attributes)

      def to_s(lbl = nil, **attrs)
        href, label, title = @href, @label, @title
        href = href.to_hash unless href.is_a?(String)
        attrs = attributes(attrs)

        context.instance_exec do
          if href.is_a?(Hash) && respond_to?(:url_text_for)
            # If href is given as a parameter Hash for url_for and we have the
            # RouteI18n module, use the module's lookup functionality, ignoring
            # label and title.
            ttl = url_text_for(href)
          else
            # Otherwise, do a regular I18n lookup for both the label and the
            # title, if they exist.
            lbl ||= I18n.t(label[:key], default: label[:fallback]) if label
            ttl = I18n.t(title[:key], default: title[:fallback]) if title
          end

          # Initialize whatever was left unitialized by the above code
          lbl ||= ttl
          ttl ||= lbl
          attrs[:title] ||= ttl

          # Finally do the render
          link_to lbl, href, **attrs
        end
      end

    end
  end
end
