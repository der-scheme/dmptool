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
        plan: lambda do |_, count: 1, unit: false, **__|
          name = count == 1 ? 'DMP' : 'DMPs'
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
          name = count == 1 ? 'Benutzer' : 'Benutzer'
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
      },
      errors: {
      }
    },
    institutions: {
      form: {
        shib_entity_id_tooltip: "Shibboleth-Endpunkt innerhalb der Förderation. Diese Einstellung kann nur durch einen DMPTool-Administator geändert werden. Bei Fragen wenden Sie sich bitte an #{i18n_join_de(APP_CONFIG['feedback_email_to'])}.",
        shib_domain_id_tooltip: "Dies kann nur durch einen DMPTool-Administrator geändert werden. Bei Fragen wenden Sie sich bitte an #{i18n_join_de APP_CONFIG['feedback_email_to']}.",
        parent_tooltip: "Falls Ihre Einrichtung nicht in der Dropdown-Liste enthalten ist, kontaktieren Sie bitte #{i18n_join_de(APP_CONFIG['feedback_email_to'])}."
      }
    },
    helpers: {
      controller: {
        plan_state: {
          state_changed: lambda do |_, state: nil, **__|
            "Der Status des DMP-Plans hat sich geändert: #{I18n.t("enum.plan_state.state.#{state}")}."
          end,
          already_in_state: lambda do |_, state: nil, **__|
            "Eine Statusänderung des DMP-Plans fand bereits statt: #{I18n.t("enum.plan_state.state.#{state}")}."
          end
        }
      }
    },
    plans: {
      create: {
        no_such_users_error: ->(_, count: nil, users: nil, **__) {"#{count == 1 ? 'Folgender Benutzer konnte' : 'Folgende Benutzer konnten'} nicht gefunden werden: #{i18n_join_de(users)}."},
        users_already_assigned_error: ->(_, count: nil, users: nil, description: nil, **__) {"#{count == 1 ? 'Der ausgewählte Benutzer ist' : 'Die ausgewählten Benutzer sind'} #{i18n_join_de(users)} bereits #{description}#{'s' if count == 1} dieses Plans."}
      },
      index: {
        visibility_tooltip: lambda do |_, parent: false, **_|
          if parent
            "Vier Sichtbarkeitsoptionen: <ul><li>Privat (rotes Schloss): lediglich Besitzer und Miteigentümer können den Plan einsehen.</li><li>Innerhalb der Institution geteilt (gelber Schlüssel): alle Benutzer die Ihrer Institution zugeordnet sind, können den Plan einsehen, kopieren und herunterladen.</li><li>Innerhalb eines Verbundes geteilt (Hierarchie-Symbol): alle Benutzer die Ihrer Institution oder einer Partnereinrichtung zugeordnet sind, können den Plan einsehen, kopieren und herunterladen.</li><li>Öffentlich zugänglich (grünes Symbol): jeder kann den Plan einsehen, kopieren und herunterladen. Außerdem wird Ihr Plan auf der Seite <a href=\"#{Rails.application.routes.url_helpers.public_dmps_path}\">#{I18n.t('routes.plans.public')}</a> einsehbar sein.</li></ul>"
          else
            "Drei Sichtbarkeitsoptionen: <ul><li>Privat (rotes Schloss): lediglich Besitzer und Miteigentümer können den Plan einsehen.</li><li>Innerhalb der Institution geteilt (gelber Schlüssel): alle Benutzer die Ihrer Institution zugeordnet sind, können den Plan einsehen, kopieren und herunterladen.</li><li>Öffentlich zugänglich (grünes Symbol): jeder kann den Plan einsehen, kopieren und herunterladen. Außerdem wird Ihr Plan auf der Seite <a href=\"#{Rails.application.routes.url_helpers.public_dmps_path}\">#{I18n.t('routes.plans.public')}</a> einsehbar sein.</li></ul>"
          end
        end
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
      },
      form: {
        review_type_tooltip_html: ->(_, **_) {"Sie können bei Plänen, die mit dieser Vorlage erstellt werden, aus drei Feedback-Optionen durch Ansprechpartner an Ihrer Einrichtung wählen.<ul><li>#{I18n.t('enum.requirements_template.review_type.formal_review')}: Bevor der Plan fertiggestellt werden kann, muss zwingend Feedback eingeholt werden.</li><li>#{I18n.t('enum.requirements_template.review_type.informal_review')}: Der Benutzer hat die Wahl, entweder den Plan abzuschließen oder Feedback einzuholen.</li><li>#{I18n.t('enum.requirements_template.review_type.no_review')}: Der Benutzer hat nicht die Möglichkeit Feedback einzuholen, sondern kann lediglich den Plan fertigstellen.</li></ul>"}
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
      model_errors: {
        message: ->(_, model: nil, **__) {"#{model.class.model_name.human} konnte nicht gespeichert werden (#{model.errors.size} Fehler):"}
      }
    },
    users: {
      create: {
        ldap_error: "Es gab Probleme beim Hinzufügen dieses Benutzers zum LDAP-Verzeichnis. Bitte kontaktieren Sie #{i18n_join_de(APP_CONFIG['feedback_email_to'])}."
      }
    },
    users_mailer: {
      information_email: {
        text: lambda do |_, name: nil, email: nil, **__|
          "Falls Sie Fragen zu dieser Aktion haben, kontaktieren Sie bitte #{"#{name} über" if name.present?}#{email}."
        end
      },
      plan_state_updated: {
        text: lambda do |_, plan: nil, state: nil, **__|
          "Der Status des DMP-Plans \"#{plan}\" hat sich geändert: #{I18n.t("enum.plan_state.state.#{state}")}"
        end
      },
      plan_visibility_changed: {
        text: lambda do |_, plan: nil, visibility: nil, institution: nil, **__|
          "Die Sichtbarkeit des Plan's \"#{plan}\" wurde auf \"#{I18n.t("enum.plan.visibility.#{visibility}")}\" geändert.\n\nDefinition der Sichtbarkeit:\n\nPrivat - Nur für Eigen- und Miteigentümer einsehbar\n\nInnerhalb der Institution - Einsehbar für alle innerhalb #{institution}\n\nÖffentlich - Für alle öffentlich einsehbar"
        end
      }
    }
  }
}
