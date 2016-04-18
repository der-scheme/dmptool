
module RouteI18n
  module Helper
    include RouteI18n::LinkHelper

    ##
    # Returns the current page's top heading text.
    #
    # Accesses I18n keys in the following order:
    #   1. '.title'
    #   2. The current page's route translation

    def top_heading_text(**options)
      t(:".title", default: url_text_i18n_keys, **options)
    end

    ##
    # Returns the current page's page title text.
    #
    # Accesses I18n keys in the following order:
    #   1. '.page_title'
    #   2. '.title_text'
    #   3. '.title'
    #   4. The current page's route translation

    def page_title(**options)
      t(:".page_title",
        default: [:".title_text", :".title", *url_text_i18n_keys], **options)
    end
  end
end
