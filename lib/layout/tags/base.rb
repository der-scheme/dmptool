
require 'layout/tags/text'

module Layout
  module Tags
    class Base
      include ActionView::Helpers

      def self.separator
        ActiveSupport::SafeBuffer.new(' | ')
      end

      attr_reader :if

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