
require 'layout/tags/text'

module Layout
  module Tags
    class Base
      include ActionView::Helpers

      attr_reader :if

      def initialize(config)
        @if = config[:if] if config.key?(:if)
      end

      def +(other)
        Text.new(other.append_to(self))
      end

      def render?(context)
        return true unless instance_variable_defined?(:@if)

        case @if
        when String then context.instance_eval(@if)
        when Proc   then context.instance_exec(&@if)
        when Symbol then context.public_send(@if)
        else             @if
        end
      end

      def wrap(wrapper, *args, **options, &block)
        # In the following code
        # - constantize is used because referencing the constant directly would
        #   make the Rails server crash on boot.
        # - const_get is used because its semantics are different from
        #   constantize.
        wrapper = "Layout::Tags::Wrappers".constantize
            .const_get(wrapper.to_s.classify, true) unless wrapper.is_a?(Class)

        wrapper.new(self, *args, **options, &block)
      end

      def append_to(other)
        other.to_s + to_s
      end

    end
  end
end
