
module RouteI18n
  module TranslationHelper

    ##
    # Returns the I18n keys for route translation lookup.
    #
    # I18n keys are composed in the following way:
    # "routes.controller.action[.format]"

    def url_text_i18n_keys(controller: nil, action: :index, format: :html,
                           **options)
      options[:controller] ||= params[:controller]
      return :"routes.#{controller}.#{action}.#{format}",
             :"routes.#{controller}.#{action}"
    end

    ##
    # Returns the localized link text for the specified url options.

    def url_text_for(default: nil, **options)
      key, fallback = url_text_i18n_keys(**options)
      default ||= [url_for(**options)]
      default.unshift(fallback)

      I18n.t(key, default: default, **options)
    end

    ##
    # Returns the localized link text for the current page.

    def current_url_text
      url_text_for params
    end

    ##
    # Defines a method "#{route.name}_text" which returns the localized link
    # text for each route available.

    def self.included(_)
      Rails.application.routes.routes.each do |route|
        define_method(:"#{route.name}_text") do |*args, **options|
          fail ArgumentError,
               "wrong number of arguments (#{args.size} for 0..1)" if
            args.size > 1

          options[:id] ||= args.first if args.size == 1
          options[:format]  ||= :html
          options[:default] ||= [route.name.titlecase]
          controller, action = route.defaults.values_at(:controller, :action)

          url_text_for(controller: controller, action: action, **options)
        end
      end
    end

  end
end
