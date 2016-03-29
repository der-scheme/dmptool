
module Layout
  module Tags
    class Text < Layout::Tags::Base

      attr_reader :text

      def initialize(text)
        @text = text
      end

      def to_s
        case text
        when self.class
          @text.text
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
