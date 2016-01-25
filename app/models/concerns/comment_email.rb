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
    #if self.comment_type == :owner
      commenter = user
      return true unless plan && commenter
      if user.prefs[:dmp_owners_and_co][:new_comment]
        UsersMailer.notification(
            user.email,
            "NEW COMMENT: #{plan.name}",
            "plan_commented",
            {:comment => self.value, :user => user, :commenter => commenter, :plan => plan } ).deliver
      end
    #end

    #mail All institutional reviewers for plan's institution
    if self.comment_type == :reviewer
      if user.prefs[:institutional_reviewers][:new_comment]
        UsersMailer.notification(
            user.email,
            "A new comment was added",
            "institutional_reviewers_new_comment",
            {:comment => self.value, :user => user, :commenter => commenter, :plan => plan } ).deliver
      end
    end
  end
end