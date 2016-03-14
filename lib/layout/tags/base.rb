
require 'layout/tags/text'

module Layout
  module Tags
    class Base
      include ActionView::Helpers

      def self.separator
        ActiveSupport::SafeBuffer.new(' | ')
      end

      def initialize(config)
        @if = config[:if] if config.key?(:if)
      end

      def +(other)
        Text.new(other.append_to(self))
      end

      def active?
        return true unless instance_variable_defined?(:@if)

        case @if
        when String then eval @if
        when Proc   then instance_exec(&@if)
        else             @if
        end
      end

      def wrap(wrapper, *args, **options)
        # In the following code
        # - constantize is used because referencing the constant directly would
        #   make the Rails server crash on boot.
        # - const_get is used because its semantics are different from
        #   constantize.
        wrapper = case wrapper
          when Symbol
            "Layout::Tags::Wrappers".constantize.const_get(wrapper, true)
          when Class
            wrapper
          else
            "Layout::Tags::Wrappers".constantize
              .const_get(wrapper.to_s.classify, true)
        end

        wrapper.new(self, *args, **options)
      end

      def append_to(other)
        other.to_s + to_s
      end

    end
  end
end
