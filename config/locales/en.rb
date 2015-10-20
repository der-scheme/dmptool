def i18n_join_en(array)
  array.join(', ').gsub(/(.*),(.*)/, '\1 or\2')
end

{
  en: {
    activerecord: {
      models: {
        comment: lambda do |_, count: nil, unit: true, **options|
          name = count == 1 ? 'Comment' : 'Comments'
          unit ? "#{count} #{name}" : name
        end,
        institution: lambda do |_, count: nil, unit: true, **options|
          name = count == 1 ? 'Institution' : 'Institutions'
          unit ? "#{count} #{name}" : name
        end,
        requirements_template: lambda do |_, count: nil, unit: true, **options|
          name = count == 1 ? 'DMP Template' : 'DMP Templates'
          unit ? "#{count} #{name}" : name
        end,
        resource_context: lambda do |_, count: nil, unit: true, **options|
          name = count == 1 ? 'DMP Template Customization' : 'DMP Template Customizations'
          unit ? "#{count} #{name}" : name
        end,
        resource: lambda do |_, count: nil, unit: true, **options|
          name = count == 1 ? 'Resource' : 'Resources'
          unit ? "#{count} #{name}" : name
        end,
        user: lambda do |_, count: nil, unit: true, **options|
          name = count == 1 ? 'User' : 'Users'
          unit ? "#{count} #{name}" : name
        end
      },
      attributes: {
        requirement: {
          text_brief: proc do |_, group: nil, **options|
            if group.nil?
              'Text brief'
            elsif group
              'Group Label'
            else
              'Requirement Label'
            end
          end
        }
      }
    },
    institutions: {
      form: {
        shib_entity_id_tooltip: "Shibboleth endpoint registered with the Incommon Federation. This can only be edited by the DMPTool Administrator. Contact #{i18n_join_en(APP_CONFIG['feedback_email_to'])} with any questions.",
        shib_domain_id_tooltip: "This can only be edited by the DMPTool Administrator. Contact #{i18n_join_en APP_CONFIG['feedback_email_to']} with any questions.",
        parent_tooltip: "If you do not see your institution listed in the dropdown list, contact #{i18n_join_en(APP_CONFIG['feedback_email_to'])}."
      }
    },
    plans: {
      create: {
        no_such_users_error: ->(_, count: nil, users: nil) {"Could not find the following #{count == 1 ? 'user' : 'users'}: #{i18n_join_en(users)}."},
        users_already_assigned_error: ->(_, count: nil, users: nil, description: nil) {"The #{count == 1 ? 'user' : 'users'} chosen #{i18n_join_en(users)} are already #{description}#{'s' if count == 1} of this Plan."}
      },
      update: {
        no_such_users_error: ->(_, count: nil, users: nil) {"Could not find the following #{count == 1 ? 'user' : 'users'}: #{i18n_join_en(users)}."},
        users_already_assigned_error: ->(_, count: nil, users: nil, description: nil) {"The #{count == 1 ? 'user' : 'users'} chosen #{i18n_join_en(users)} are already #{description}#{'s' if count == 1} of this Plan."}
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
    },
    users: {
      create: {
        ldap_error: "There were problems adding this user to the LDAP directory. Please contact #{i18n_join_en(APP_CONFIG['feedback_email_to'])}."
      }
    }
  }
}