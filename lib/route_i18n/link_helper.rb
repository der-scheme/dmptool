
require 'route_i18n/translation_helper'

module RouteI18n
  module LinkHelper
    include TranslationHelper

    ##
    # Defines a method "link_to_#{route.name}" which generates a link to
    # "#{route.name}_path", labelled with the "#{route.name}_text" for each
    # route available.

    def self.included(_)
      Rails.application.routes.routes.each do |route|
        define_method(:"link_to_#{route.name}") do |url = {},
                                                    html_options = {}, &body|
          url = {id: url.id} if url.is_a? ActiveRecord::Base
          text = send(:"#{route.name}_text")

          link_to route.defaults.merge(url), html_options do
            body ? body.call(text) : text
          end
        end
      end
    end

  end
end
