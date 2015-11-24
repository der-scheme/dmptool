
require 'route_i18n/translation_helper'

module RouteI18n
  module LinkHelper
    include TranslationHelper

    ##
    # Defines a method "link_to_#{name}" which generates a link to
    # "#{name}_path", labelled with the "#{name}_text", for the given +route+.

    def self.add(name, route)

      ##
      # Returns a labelled link to the route in question.
      #
      # :call-seq: link_to_route_name(html_options = {}) {|text| …}?
      # :call-seq: link_to_route_name(url = {}, html_options = {}) {|text| …}?

      define_method(:"link_to_#{route.name}") do |url = nil,
                                                  html_options = nil, &body|
        url, html_options = {}, url if url.is_a?(Hash) && html_options.nil?
        html_options ||= {}
        t = html_options.delete(:t)

        route_name_text = :"#{route.name}_text"
        text = send(route_name_text, t: t, **(url.is_a?(Hash) ? url : {}))

        link_to send(:"#{route.name}_path", url), html_options do
          body ? body.call(text) : text
        end
      end
    end

  end
end

class ActionDispatch::Routing::RouteSet::NamedRouteCollection
  mod = Module.new do
    def add(name, route)
      RouteI18n::LinkHelper.add(name, route)

      super
    end
  end

  prepend mod
end
