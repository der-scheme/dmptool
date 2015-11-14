
module RouteI18n
  module TranslationHelper

    ##
    # Returns the localized link text for the specified url options.
    #
    # I18n keys are composed in the following way:
    # "routes.controller.action[.format]"

    def url_text_for(controller: nil, action: :index, format: :html, **options)
      controller ||= params[:controller]
      options[:default] ||= [
                              url_for(controller: controller, action: action,
                                      format: format, **options)
                            ]

      result = I18n.t(action, scope: [:routes, controller], **options)
      return result unless result.is_a?(Hash)

      I18n.t(format, scope: [:routes, controller, action], **options)
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
