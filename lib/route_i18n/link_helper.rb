
module RouteI18n
  module LinkHelper
    include RouteI18n::TranslationHelper

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
        format = html_options.delete(:format)
        locale = html_options.delete(:locale) || params[:locale]
        t = html_options.delete(:t)

        text_method = :"#{route.name}_text"
        path_method = :"#{route.name}_path"

        if url.is_a?(Hash)
          url[:format] ||= format
          url[:locale] ||= locale

          text = send(text_method, t: t, **url)
          link_to send(path_method, **url), html_options do
            body ? body.call(text) : text
          end
        else
          text = send(text_method, url, format: format, locale: locale, t: t)
          link_to send(path_method, url, format: format, locale: locale),
                  html_options do
            body ? body.call(text) : text
          end
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
