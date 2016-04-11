
class Layout
  module Tags

    ##
    # A virtual tag that is rendered as a list item with a link and, if
    # available, a list of children.
    #
    # === Configuration ===
    # Configured by a Hash, supporting the following keys, as well as the
    # options supported by the A tag.
    # [:children]
    #     The child navigation items. May be +nil+ for no children, or any
    #     collection of NavItem configurations.

    class NavItem < Layout::Tags::A

      ##
      # Reader for the child items.

      attr_reader :children

      def initialize(context, config)
        @children = config[:children].try(:map) do |cconfig|
          self.class.new(context, cconfig)
        end

        super
      end

      def to_s
        children, href = @children, @href
        super_to_s = super.to_s

        context.instance_exec do
          cls = ''
          cls = "nav-#{href[:controller]}-#{href[:action]}" if href.is_a?(Hash)
          cls << ' parent' if children

          item = children ?
            super_to_s + content_tag(:ul, children.reduce(&:+), class: 'children right') :
            super_to_s

          content_tag(:li, item, class: cls)
        end
      end
    end
  end
end
