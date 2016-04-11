
class Layout
  module Tags

    ##
    # A virtual tag that renders to plain HTML text.

    class Text < Layout::Tags::Base

      ##
      # Reader for the text contents.

      attr_reader :text

      def initialize(context, text)
        @text = text
        super(context)
      end

      def to_s
        case text
        when self.class
          @text.text.to_s
        when Hash
          context.t(text[:key], default: text[:fallback])
        when Proc
          context.instance_exec(&text)
        else
          text.to_s
        end
      end

    end
  end
end
