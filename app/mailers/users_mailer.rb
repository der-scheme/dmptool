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

  def plan_user_added(recipient, user_plan)
    @recipient = recipient
    @user, @plan = user_plan.user, user_plan.plan

    @user.define_singleton_method(:owner?) {user_plan.owner?}

    mail to: recipient,
         subject: "New #{@user.owner? ? 'owner' : 'co-owner'} of #{@plan.name}"
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