
module Layout
  module Tags

    ##
    # A virtual tag that renders to plain HTML text.

    class Text < Layout::Tags::Base

      ##
      # Reader for the text contents.

      attr_reader :text

      def initialize(text)
        @text = text
      end

      def to_s
        case text
        when self.class
          @text.text.to_s
        when Hash
          I18n.t(text[:key], default: text[:fallback])
        when Proc
          text.call
        else
          text.to_s
        end
      end

    end
  end
end
