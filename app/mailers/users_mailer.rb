class UsersMailer < ActionMailer::Base
  default from: APP_CONFIG['feedback_email_from'],
          reply_to: APP_CONFIG['feedback_email_to']

  ##
  # Override the default mail method and prepend a string to the subject

  def mail(*args, **options)
    options[:subject].try(:prepend, dmp_string + ' ')
    options[:to] = options[:to].email if options[:to].is_a? ActiveRecord::Base
    super(*args, **options)
  end

  def username_reminder(uid, email)
    @uid = uid
    @email = email
    mail to: email, subject: 'username reminder' do |format|
      format.text {render layout: 'plain'}
    end
  end

  def password_reset(uid, email, reset_path)
    @uid = uid
    @url = reset_path
    mail to: email, subject: 'password reset' do |format|
      format.text {render layout: 'plain'}
    end
  end

  #pass in the email addresses, the email subject and the template name that has the text

  #an example call:
  # UsersMailer.notification(['catdog@mailinator.com', 'dogdog@mailinator.com'],
  #                           'that frosty mug taste', 'test_mail').deliver
  def notification(email_address, subject, message_template, locals)
    email_address_array = [*email_address]
    @plan = locals.delete(:plan)
    @user = locals.delete(:user)
    @recipient = @user
    @vars = locals
    mail to:            email_address_array.join(','),
         subject:       subject,
         template_name: message_template
  end

  def plan_commented(recipient, comment, institutional: false)
    @author = comment.user
    @comment = comment
    @institutional = institutional
    @plan = comment.plan
    @recipient = recipient

    mail to: recipient.email,
         subject: "New comment: #{@plan.name}"
  end

  def plan_completed(recipient, plan)
    @plan = plan
    @recipient = recipient

    mail to: recipient, subject: "PLAN COMPLETED: #{plan.name}"
  end

  def plan_state_updated(recipient, plan, institutional: false)
    @institutional = institutional
    @plan = plan
    @recipient = recipient

    mail to: recipient, subject: "DMP #{plan.current_state.state}: #{plan.name}"
  end

  def plan_under_review(recipient, plan)
    @plan = plan
    @recipient = recipient

    mail to: recipient,
         subject: "#{plan.name} has been submitted for institutional review"
  end

  def plan_user_added(recipient, user_plan)
    @recipient = recipient
    @user, @plan = user_plan.user, user_plan.plan

    @user.define_singleton_method(:owner?) {user_plan.owner?}

    mail to: recipient,
         subject: "New #{@user.owner? ? 'owner' : 'co-owner'} of #{@plan.name}"
  end

  def plan_visibility_changed(recipient, plan)
    @plan = plan
    @recipient = recipient

    mail to: recipient, subject: "DMP Visibility Changed: #{plan.name}"
  end

  def user_role_granted(recipient, role_ids)
    @recipient = recipient
    @granted_roles = Role.where(id: role_ids).pluck(:name).join(', ')
    @all_roles = recipient.roles.pluck(:name).join(', ')

    mail to: recipient, subject: "#{@granted_roles} Activated"
  end

private

  def dmp_string
    case ENV["RAILS_ENV"]
    when 'development'
      "[DMPTool] (development)"
    when 'stage'
      "[DMPTool] (staging)"
    when 'production'
      "[DMPTool]"
    end
  end

end