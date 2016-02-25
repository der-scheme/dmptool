def i18n_join_en(array)
  array.join(', ').gsub(/(.*),(.*)/, '\1 or\2')
end

{
  en: {
    activerecord: {
      models: {
        additional_information: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Funder Link' : 'Funder Links'
          unit ? "#{count} #{name}" : name
        end,
        comment: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Comment' : 'Comments'
          unit ? "#{count} #{name}" : name
        end,
        institution: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Institution' : 'Institutions'
          unit ? "#{count} #{name}" : name
        end,
        requirements_template: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'DMP Template' : 'DMP Templates'
          unit ? "#{count} #{name}" : name
        end,
        resource_context: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'DMP Template Customization' : 'DMP Template Customizations'
          unit ? "#{count} #{name}" : name
        end,
        resource: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Resource' : 'Resources'
          unit ? "#{count} #{name}" : name
        end,
        sample_plan: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Sample Plan' : 'Sample Plans'
          unit ? "#{count} #{name}" : name
        end,
        user: lambda do |_, count: 1, unit: false, **__|
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
      },
      errors: {
      }
    },
    globals: {
      appname: lambda do |_, **__|
        case ENV["RAILS_ENV"]
        when 'development' then 'DMPTool (development)'
        when 'state'       then 'DMPTool (staging)'
        else                    'DMPTool'
        end
      end
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
        no_such_users_error: ->(_, count: nil, users: nil, **__) {"Could not find the following #{count == 1 ? 'user' : 'users'}: #{i18n_join_en(users)}."},
        users_already_assigned_error: ->(_, count: nil, users: nil, description: nil, **__) {"The #{count == 1 ? 'user' : 'users'} chosen #{i18n_join_en(users)} are already #{description}#{'s' if count == 1} of this Plan."}
      },
      form: {
        visibility_note_html: ->(_, **_) {"<span>Note: when visibility is set to \"Public\", your DMP will appear on the <a href=\"#{Rails.application.routes.url_helpers.public_dmps_path}\">#{I18n.t('routes.plans.public')}</a> page of this site and it will be downloadable and copy-able. </span>"}
      },
      index: {
        visibility_tooltip: lambda do |_, parent: false, **_|
          if parent
            "Four possible states:<ul><li>Private (red lock): only owners and co-owners can view the plan.</li><li>Shared with institution (yellow key): anyone logged in from your entire institution hierarchy can view, copy and or download the plan.</li><li>Shared within unit (hierarchy icon): anyone logged in from your institution or from a parent institution can view, copy and or download the plan. </li><li>Share publicly (green people): anyone can view, copy and or download the plan. Your DMP will appear on the <a href=\"#{Rails.application.routes.url_helpers.public_dmps_path}\">#{I18n.t('routes.plans.public')}</a> page of this site.</li></ul>"
          else
            "Three possible states:<ul><li>Private (red lock): only owners and co-owners can view the plan.</li><li>Shared with institution (yellow key): anyone logged in from your institution can view, copy and or download the plan.</li><li>Share publicly (green people): anyone can view, copy and or download the plan. Your DMP will appear on the <a href=\"#{Rails.application.routes.url_helpers.public_dmps_path}\">#{I18n.t('routes.plans.public')}</a> page of this site.</li></ul>"
          end
        end
      },
      update: {
        no_such_users_error: ->(_, count: nil, users: nil, **__) {"Could not find the following #{count == 1 ? 'user' : 'users'}: #{i18n_join_en(users)}."},
        users_already_assigned_error: ->(_, count: nil, users: nil, description: nil, **__) {"The #{count == 1 ? 'user' : 'users'} chosen #{i18n_join_en(users)} are already #{description}#{'s' if count == 1} of this Plan."}
      }
    },
    requirements_templates: {
      index: {
        toggle_status_link: ->(_, template: nil, **__) {template.active ? 'Deactivate' : 'Activate'}
      },
      toggle_active: {
        toggle_status_link: ->(_, template: nil, **__) {template.active ? 'Deactivate' : 'Activate'}
      },
      form: {
        review_type_tooltip_html: ->(_, **_) {"You can require institutional administrator review of plans submitted using this template.<ul><li>#{I18n.t('enum.requirements_template.review_type.formal_review')}: Review process is mandatory, such that the plan can only be finished after the review process is done.</li><li>#{I18n.t('enum.requirements_template.review_type.informal_review')}: The user can choose to finish the plan or to use the review process.</li><li>#{I18n.t('enum.requirements_template.review_type.no_review')}: The user is not able to use the review process. His only option is to finish the plan.</li></ul>"}
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
      },
      model_errors: {
        message: ->(_, model: nil, **__) {"#{model.errors.size} error#{'s' if model.errors.size != 1} prohibited this #{model.class.model_name.human} from being saved:"}
      }
    },
    users: {
      create: {
        ldap_error: "There were problems adding this user to the LDAP directory. Please contact #{i18n_join_en(APP_CONFIG['feedback_email_to'])}."
      }
    },
    users_mailer: {
      information_email: {
        text: lambda do |_, name: nil, email: nil, **__|
          "If you have questions pertaining to this action, please contact #{"#{name} at " if name.present?}#{email}."
        end
      },
      plan_state_updated: {
        text: lambda do |_, plan: nil, state: nil, **__|
          "The DMP \"#{plan}\" has been #{I18n.t("enum.plan_state.state.#{state}")}."
        end
      },
      plan_visibility_changed: {
        text: lambda do |_, plan: nil, visibility: nil, institution: nil, **__|
          "The plan \"#{plan}\" has had its visibility changed to #{I18n.t("enum.plan.visibility.#{visibility}")}.\n\nVisibility definitions:\n\nPrivate - Visible to owners and co-owners only\n\nInstitutional - Visible to others from #{institution}\n\nPublic - visible publicly on the web"
        end
      }
    }
  }
}
