
##

class Layout
  module Tags

    ##
    # Base class for all (literal and virtual) HTML tags, compatible with layout
    # configuration options.
    #
    # === Configuration ===
    # Configured by a Hash, supporting the following keys, as well as the
    # options supported by the Base class.
    # [:if]
    #     A conditional to be executed in the #render? method. May be a String,
    #     in which case it is _instance_eval_'d in the context, a Proc, in
    #     which case it is _instance_exec_'d in the context, a Symbol, in which
    #     case the context's method denoted by the Symbol is called, or anything
    #     else, in which case it is just returned literally.

    class Base

      ##
      # Reader for the view context where we render everything

      attr_reader :context

      ##
      # Reader for the conditional to be executed in the #render? method.

      attr_reader :if

      def initialize(context, config = {})
        @context = context
        @class = config[:class]
        @if = config[:if] if config.key?(:if)
      end

      ##
      # Returns a tag representing _other_ appended to +self+.

      def +(other)
        Text.new(context, other.append_to(self))
      end

      ##
      # Returns this HTML tag's attributes.
      #
      # If more are given as parameters, merges them in a smart way (i.e. by
      # concatenating CSS classes).

      def attributes(params = {})
        params.merge(class: join_values(@class, params[:class]))
      end

      ##
      # Returns true if the tag should be rendered in the _context_, false
      # otherwise.
      #
      # Executes #if in instance scope of _context_ (if at all possible).

      def render?
        return true unless instance_variable_defined?(:@if)

        case @if
        when String then context.instance_eval(@if)
        when Proc   then context.instance_exec(&@if)
        when Symbol then context.public_send(@if)
        else             @if
        end
      end

      ##
      # Returns a Wrapper around +self+, passing all parameters but the first
      # to the Wrapper constructor.
      #
      # The _wrapper_ parameter, if not a Class, is (classified and) searched
      # for in the Layout::Tags::Wrappers namespace.

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

      ##
      # Renders both _other_ and +self+ and return the concatenation.

      def append_to(other)
        other.to_s + to_s
      end

    private

      def join_values(*values)
        values.compact.join(' ')
      end

    end
  end
end
