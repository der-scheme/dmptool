
require 'route_i18n/translation_helper'

module RouteI18n
  module LinkHelper
    include TranslationHelper

    ##
    # Defines a method "link_to_#{route.name}" which generates a link to
    # "#{route.name}_path", labelled with the "#{route.name}_text", for the
    # given +route+.

    def self.add(route)

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

        # I have no idea why I have to insert the locale manually. Also,
        # default_url_options seems to be empty at this point, no matter what I
        # try.
        link_to send(:"#{route.name}_path", url, locale: params[:locale]), html_options do
          body ? body.call(text) : text
        end
      end
    end

  end
end

class ActionDispatch::Routing::RouteSet::NamedRouteCollection
  mod = Module.new do
    def define_url_helper(route, *args)
      RouteI18n::LinkHelper.add(route)

      super(route, *args)
    end
  end

  prepend mod
end
