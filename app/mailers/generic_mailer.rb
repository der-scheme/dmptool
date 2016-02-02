class GenericMailer < ActionMailer::Base
  default :from => APP_CONFIG['feedback_email_from']

  before_filter :set_url_options

  def contact_email(form_hash, email)
    # values :question_about, :name, :email, :message
    @form_hash = form_hash
    mail :to => email,
         :reply_to => form_hash[:email],
         :subject => 'DMPTool2 Contact Us Form Feedback',
         :from => APP_CONFIG['feedback_email_from']
  end

private
  def set_url_options
    ActionMailer::Base.default_url_options[:locale] ||= nil
  end

end