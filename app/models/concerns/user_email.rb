module UserEmail
  # these concerns are for notification emails
  #extend ActiveSupport::Concern

  #included do
  #  after_create :email_role_granted
  #end

  # [:users][:role_granted]
  def email_roles_granted(granted_roles)
    # I believe this should notify the user who is granted the role
    if self[:prefs][:users][:role_granted] && granted_roles.present?
      UsersMailer.user_role_granted(self, granted_roles).deliver
    end
  end
end