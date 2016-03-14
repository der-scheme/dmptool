
require 'layout/tags/base'

module Layout
  module Tags
    class Text < Base
      def initialize(text)
        @text = text
      end

      def to_s
        return unless active?

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

    protected

      attr_reader :text

    end
  end
end
