module ResourceContextEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_destroy :resource_context_destroy
  end

  # for these notifications:
  # [:resource_editors][:deleted] - A customization is deleted
  def resource_context_destroy
    # only notify for customizations being deleted, not other kinds
    return unless institution && requirement.nil? && resource.nil?

    institution.users_in_and_above_inst_in_role(Role::RESOURCE_EDITOR)
      .concat(institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_ADMIN))
      .uniq.select {|user| user[:prefs][:resource_editors][:deleted]}
      .each do |recipient|
        UsersMailer.template_customization_deleted(recipient, self).deliver
    end
  end
end