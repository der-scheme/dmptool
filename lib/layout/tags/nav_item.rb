
require 'layout/tags/a'

module Layout
  module Tags
    class NavItem < A
      include ApplicationHelper

      attr_reader :children

      def initialize(config)
        @children = config[:children].try(:map) do |cconfig|
          self.class.new(cconfig)
        end

        super(config)
      end

      def to_s
        cls = "nav-#{href[:controller]}-#{href[:action]}" if href.is_a?(Hash)
        cls << ' parent' if children

        item = children ?
          super + content_tag(:ul, children.reduce(&:+), class: 'children right') :
          super

        content_tag(:li, item, class: cls)
      end
    end
  end
end
