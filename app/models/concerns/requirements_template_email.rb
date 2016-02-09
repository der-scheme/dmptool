module RequirementsTemplateEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_save :email_template_saved
  end

  # for these notifications:
  # [:requirement_editors][:deactived] - An institutional DMP template is deactivated
  # [:requirement_editors][:committed] - An institutional DMP template is activated
  # [:resource_editors][:associated_committed] - A DMP Template associated with a customization is activated
  def email_template_saved
    template_editors = proc do    # Fake lazy loading.
      institution.users_in_and_above_inst_in_role(Role::TEMPLATE_EDITOR)
        .concat(institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_ADMIN))
        .uniq
    end

    # [:requirement_editors][:deactived] - An institutional DMP template is deactivated
    if !active && changes[:active] && changes[:active][0]
      template_editors.call
        .select {|user| user[:prefs][:requirement_editors][:deactived]}
        .each {|user| UsersMailer.template_deactivated(user, self).deliver}

    # [:requirement_editors][:committed] - An institutional DMP template is activated (committed)
    # [:resource_editors][:associated_committed] - A DMP Template associated with a customization is activated
    elsif active && changes[:active] && !changes[:active][0]
      # this is for requirement editors
      template_editors.call
        .select {|user| user[:prefs][:requirement_editors][:committed]}
        .each {|user| UsersMailer.template_activated(user, self).deliver}

      #this is for customizations and resource editors associated them that use this template
      # customization type 'Container - Institution',
      # inst: set,     req_temp: set,     req: not set,     resource: not set
      customizations = ResourceContext
          .where('institution_id IS NOT NULL AND requirement_id IS NULL AND resource_id IS NULL')
          .where(requirements_template_id: id)

      #for each customization that uses this resource template that has been made active notify resource editors
      customizations.each do |customization|
        customization.institution
          .users_in_and_above_inst_in_role(Role::RESOURCE_EDITOR)
          .concat(institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_ADMIN))
          .uniq.select {|user| user[:prefs][:resource_editors][:associated_committed]}
          .each do |recipient|
            UsersMailer
              .customized_template_activated(recipient, self, customization)
              .deliver
        end
      end
    end

  end
end