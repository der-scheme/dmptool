module UserPlanEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_coowner_added
  end

  # [:dmp_owners_and_co][:user_added] -- I have been made a co-owner of a DMP
  def email_coowner_added
    # mail all owners and co-owners

    return if self.owner? #do not email owners until later when someone changes their minds

    plan
      .users.select {|u| u.prefs[:dmp_owners_and_co][:user_added]}
      .each {|recipient| UsersMailer.plan_user_added(recipient, self).deliver}
  end
end