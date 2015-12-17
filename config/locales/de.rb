def i18n_join_de(array)
  array.join(', ').gsub(/(.*),(.*)/, '\1 or\2')
end

{
  de: {
    activerecord: {
      models: {
        additional_information: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Link zum Drittmittelgeber' : 'Links zum Drittmittelgeber'
          unit ? "#{count} #{name}" : name
        end,
        comment: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Kommentar' : 'Kommentare'
          unit ? "#{count} #{name}" : name
        end,
        institution: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Einrichtung' : 'Einrichtungen'
          unit ? "#{count} #{name}" : name
        end,
        requirements_template: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'DMP-Vorlage' : 'DMP-Vorlagen'
          unit ? "#{count} #{name}" : name
        end,
        resource_context: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Anpassung einer DMP-Vorlage' : 'Anpassungen einer DMP-Vorlage'
          unit ? "#{count} #{name}" : name
        end,
        resource: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Ressource' : 'Ressourcen'
          unit ? "#{count} #{name}" : name
        end,
        sample_plan: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'Musterplan' : 'Musterpläne'
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
              'Kurztext'
            elsif group
              'Bezeichnung der Gruppe'
            else
              'Bezeichnung des Unterpunkts'
            end
          end
        }
      }
    },
    institutions: {
      form: {
        shib_entity_id_tooltip: "Shibboleth-Endpunkt innerhalb der Förderation. Diese Einstellung kann nur durch einen DMPTool-Administator geändert werden. Bei Fragen wenden Sie sich bitte an #{i18n_join_de(APP_CONFIG['feedback_email_to'])}.",
        shib_domain_id_tooltip: "Dies kann nur durch einen DMPTool-Administrator geändert werden. Bei Fragen wenden Sie sich bitte an #{i18n_join_de APP_CONFIG['feedback_email_to']}.",
        parent_tooltip: "Falls Ihre Einrichtung nicht in der Dropdown-Liste enthalten ist, kontaktieren Sie bitte #{i18n_join_de(APP_CONFIG['feedback_email_to'])}."
      }
    },
    plans: {
      create: {
        no_such_users_error: ->(_, count: nil, users: nil, **__) {"#{count == 1 ? 'Folgender Benutzer konnte' : 'Folgende Benutzer konnten'} nicht gefunden werden: #{i18n_join_de(users)}."},
        users_already_assigned_error: ->(_, count: nil, users: nil, description: nil, **__) {"#{count == 1 ? 'Der ausgewählte Benutzer ist' : 'Die ausgewählten Benutzer sind'} #{i18n_join_de(users)} bereits #{description}#{'s' if count == 1} dieses Plans."}
      },
      form: {
        visibility_note_html: "<span>Hinweis: Wenn bei der Sichtbarkeit \"Öffentlich\" eingestellt ist, wird Ihr DMP auf der Seite <a href=\"#{Rails.application.routes.url_helpers.public_dmps_path}\">Beispiel-DMPs</a> erscheinen. Er wird herunterladbar und dublizierbar sein.</span>"
      },
      update: {
        no_such_users_error: ->(_, count: nil, users: nil, **__) {"#{count == 1 ? 'Folgender Benutzer konnte' : 'Folgende Benutzer konnten'} nicht gefunden werden: #{i18n_join_de(users)}."},
        users_already_assigned_error: ->(_, count: nil, users: nil, description: nil, **__) {"#{count == 1 ? 'Der ausgewählte Benutzer ist' : 'Die ausgewählten Benutzer sind'} #{i18n_join_de(users)} bereits #{description}#{'s' if count == 1} dieses Plans."}
      }
    },
    requirements_templates: {
      index: {
        toggle_status_link: ->(_, template: nil, **__) {template.active ? 'Deaktivieren' : 'Aktivieren'}
      },
      toggle_active: {
        toggle_status_link: ->(_, template: nil, **__) {template.active ? 'Deaktivieren' : 'Aktivieren'}
      }
    },
    resource_contexts: {
      customization_resources_list: {
        resources_customized_for:
          lambda do |key,
                     template: fail(ArgumentError, 'DMP-Vorlage nicht vorhanden'),
                     institution: nil,
                     **options|
            if institution
              "Ressourcen für #{template}  - angepasst für: %{institution}"
            else
              "Ressourcen für #{template}  - angepasst für alle Einrichtungen"
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
            "Alle"
          end
        end
      },
      errors: {
        message: ->(_, model: nil, **__) {"#{model.errors.size} Fehler #{model.errors.size == 1 ? 'verhinderte' : 'verhinderten'}, dass #{model.class.model_name.human.downcase} gespeichert wurde:"}
      }
    },
    users: {
      create: {
        ldap_error: "Es gab Probleme beim Hinzufügen dieses Benutzers zum LDAP-Verzeichnis. Bitte kontaktieren Sie #{i18n_join_de(APP_CONFIG['feedback_email_to'])}."
      }
    }
  }
}
