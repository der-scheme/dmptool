
require 'layout/tags/base'

module Layout
  module Tags
    class A < Base
      include ActionDispatch::Routing
      include Rails.application.routes.url_helpers
      # Conditional include, depending on wether we have merged this with a
      # branch that supports route_i18n
      include RouteI18n::TranslationHelper if const_defined?(:RouteI18n)

      def initialize(config)
        @href, @label, @title = config.values_at(:href, :label, :title)
      end

      def to_s(label = nil, **attributes)
        if @href.is_a?(Hash) && self.class.const_defined?(:RouteI18n)
          title = url_text_for(@href)
        else
          label ||= I18n.t(@label[:key], default: @label[:fallback]) if @label
          title = I18n.t(@title[:key], default: @title[:fallback]) if @title
        end

        label ||= title
        title ||= label
        attributes[:title] ||= title

        link_to label, @href, **attributes
      end
    end
  end
end
