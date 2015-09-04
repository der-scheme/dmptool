{
  en: {
    institutions: {
      form: {
        shib_entity_id_tooltip: "Shibboleth endpoint registered with the Incommon Federation. This can only be edited by the DMPTool Administrator. Contact #{APP_CONFIG['feedback_email_to'].join(', ').gsub(/(.*),(.*)/, '\1 or\2')} with any questions.",
        shib_domain_id_tooltip: "This can only be edited by the DMPTool Administrator. Contact #{APP_CONFIG['feedback_email_to'].join(', ').gsub(/(.*),(.*)/, '\1 or\2')} with any questions.",
        parent_tooltip: "If you do not see your institution listed in the dropdown list, contact #{APP_CONFIG['feedback_email_to'].join(', ').gsub(/(.*),(.*)/, '\1 or\2')}."
      }
    },
    resource_contexts: {
      customization_resources_list: {
        resources_customized_for:
          lambda do |key,
                     template: fail(ArgumentError, 'template missing'),
                     institution: nil,
                     **options|
            if institution
              "Template Resources for #{template}  - Customized for %{institution}"
            else
              "Template Resources for #{template}  - Customized for all Institutions"
            end
          end
      }
    },
    shared: {
      button_link: {
        filter: lambda do |key, s: nil, e: nil, **options|
          s = s.to_s.upcase
          e = e.to_s.upcase

          if s != 'A' || e != 'Z'
            "#{s} - #{e}"
          else
            "All"
          end
        end
      }
    }
  }
}
