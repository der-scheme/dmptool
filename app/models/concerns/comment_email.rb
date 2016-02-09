module CommentEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_new_comment
  end

  # for both dmp_owners_and_co and institutional reviewers
  # [:dmp_owners_and_co][:new_comment]
  # [:institutional_reviewers][:new_comment]
  def email_new_comment

    #mail all owners and co-owners for a plan that has a new comment
    plan.users
      .reject {|recipient| user == recipient}
      .select {|user| user[:prefs][:dmp_owners_and_co][:new_comment]}
      .each {|recipient| UsersMailer.plan_commented(recipient, self).deliver}

    #mail All institutional reviewers for plan's institution
    return unless comment_type == :reviewer

    user.institution
      .users_in_and_above_inst_in_role(Role::INSTITUTIONAL_REVIEWER)
      .reject {|recipient| user == recipient}
      .select {|user| user[:prefs][:institutional_reviewers][:new_comment]}
      .each do |recipient|
        UsersMailer.plan_commented(recipient, self, institutional: true).deliver
    end

  end
end