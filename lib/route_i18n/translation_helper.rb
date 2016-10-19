
module RouteI18n
  module TranslationHelper

    ##
    # Returns the I18n keys for route translation lookup.
    #
    # I18n keys are composed in the following way:
    # "routes.controller.action[.format]"

    def url_text_i18n_keys(controller: nil, action: nil, format: :html,
                           **options)
      action ||= controller ? :index : params[:action]
      controller ||= params[:controller]
      return :"routes.#{controller}.#{action}.#{format}",
             :"routes.#{controller}.#{action}"
    end

    ##
    # Returns the localized link text for the specified url options.

    def url_text_for(url_options = {}, t: nil, default: nil, **options)
      url_options = url_options.merge(options)
      key, fallback = url_text_i18n_keys(**url_options)
      default ||= url_text_defaults(url_options)
      default.unshift(fallback)
      t &&= scope_key_by_partial(t)

      return I18n.t(key, default: default, **url_options) unless t
      I18n.t(t, default: default.unshift(t), **url_options)
    end

    ##
    # Returns the localized link text for the current page.

    def current_url_text
      url_text_for params
    end

    ##
    # Defines a method "#{route.name}_text" which returns the localized link
    # text for the given +route+.

    def self.add(route)
      define_method(:"#{route.name}_text") do |*args, t: nil, **options|
        fail ArgumentError,
             "wrong number of arguments (#{args.size} for 0..1)" if
          args.size > 1

        options[:id] ||= args.first if args.size == 1
        options[:format]  ||= :html
        options[:default] ||= [route.name.titlecase]
        controller, action = route.defaults.values_at(:controller, :action)

        url_text_for(controller: controller, action: action, t: t, **options)
      end
    end

  private

    ##
    # Returns a proc that returns text derived from calling #url_for with
    # +url_options+ that is nicer to the human eye than a plain URL.

    def url_text_defaults(url_options)
      [proc {url_for(**url_options).from(1).titleize.presence || 'Home'}]
    end

  end
end

class ActionDispatch::Routing::RouteSet::NamedRouteCollection
  mod = Module.new do
    def define_url_helper(route, *args)
      RouteI18n::TranslationHelper.add(route)

      super(route, *args)
    end
  end

  prepend mod
end
