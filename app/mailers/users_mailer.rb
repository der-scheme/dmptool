class UsersMailer < ActionMailer::Base
  default from: APP_CONFIG['feedback_email_from']

  def username_reminder(uid, email)
    @uid = uid
    @email = email
    mail to: email, subject: 'DMPTool username reminder'
  end

  def password_reset(uid, email, reset_path)
    @uid = uid
    @url = reset_path
    mail to: email, subject: 'DMPTool password reset'
  end

  #pass in the email addresses, the email subject and the template name that has the text

  #an example call:
  # UsersMailer.notification(['catdog@mailinator.com', 'dogdog@mailinator.com'],
  #                           'that frosty mug taste', 'test_mail').deliver
  def notification(email_address, subject, message_template, locals)
    email_address_array = [*email_address]
    @user = locals.delete(:user)
    @vars = locals
    mail to:            email_address_array.join(','),
         subject:       "#{dmp_string} #{subject}",
         reply_to:      APP_CONFIG['feedback_email_from'],
         template_name: message_template
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