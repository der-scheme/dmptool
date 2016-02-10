class UsersMailer < ActionMailer::Base
  default from: APP_CONFIG['feedback_email_from'],
          reply_to: APP_CONFIG['feedback_email_to']
  helper RouteI18n::Helper
  layout 'plain', only: [:password_reset, :username_reminder]

  ##
  # Override the default mail method and prepend a string to the subject

  def mail(*args, **options)
    options[:subject] ||= t('.subject')
    options[:subject].try(:prepend, "[#{t('globals.appname')}] ")
    options[:to] ||= @recipient
    options[:to] = options[:to].email if options[:to].is_a? ActiveRecord::Base
    super(*args, **options)
  end

  before_filter :set_url_options

  def username_reminder(uid, email)
    @uid = uid
    @email = email
    mail to: email, subject: 'username reminder'
  end

  def password_reset(uid, email, reset_path)
    @uid = uid
    @url = reset_path
    mail to: email, subject: 'password reset'
  end

  def customized_template_activated(recipient, template, customization)
    @customization = customization
    @recipient = recipient
    @template = template

    mail subject: "DMP Template Activated: #{template.name}"
  end

  def plan_commented(recipient, comment, institutional: false)
    @author = comment.user
    @comment = comment
    @institutional = institutional
    @plan = comment.plan
    @recipient = recipient

    mail subject: "New comment: #{@plan.name}"
  end

  def plan_completed(recipient, plan)
    @plan = plan
    @recipient = recipient

    mail subject: "PLAN COMPLETED: #{plan.name}"
  end

  def plan_state_updated(recipient, plan, institutional: false)
    @institutional = institutional
    @plan = plan
    @recipient = recipient

    mail subject: "DMP #{plan.current_state.state}: #{plan.name}"
  end

  def plan_under_review(recipient, plan)
    @plan = plan
    @recipient = recipient

    mail subject: "#{plan.name} has been submitted for institutional review"
  end

  def plan_user_added(recipient, user_plan)
    @recipient = recipient
    @user, @plan = user_plan.user, user_plan.plan

    @user.define_singleton_method(:owner?) {user_plan.owner?}

    mail subject: "New #{@user.owner? ? 'owner' : 'co-owner'} of #{@plan.name}"
  end

  def plan_visibility_changed(recipient, plan)
    @plan = plan
    @recipient = recipient

    mail subject: "DMP Visibility Changed: #{plan.name}"
  end

  def template_activated(recipient, template)
    @recipient = recipient
    @template = template

    mail subject: "DMP Template Activated: #{template.name}"
  end

  def template_deactivated(recipient, template)
    @recipient = recipient
    @template = template

    mail subject: "DMP Template Deactivated: #{template.name}"
  end

  def user_role_granted(recipient, role_ids)
    @recipient = recipient
    @granted_roles = Role.where(id: role_ids).pluck(:name).join(', ')
    @all_roles = recipient.roles.pluck(:name).join(', ')

    mail subject: "#{@granted_roles} Activated"
  end

  def template_customization_deleted(recipient, customization)
    @customization = customization
    @recipient = recipient

    mail subject: "DMP Template Customization Deleted: #{customization.requirements_template.name}"
  end

private
  def set_url_options
    default_url_options[:locale] ||= nil
  end

  ##
  # Augment the original #_render_template method.
  #
  # If there is more than one locale available to the application, we assume
  # that this email might reach users that might usually use the application
  # with other locales than the default one.
  # Therefore, we basically just call the +super+ method once per locale and
  # return a message with all of its translations.
  #
  # Note: This currently only works for text views and most likely will fail
  # with HTML/multipart emails.

  def _render_template(*args, **options)
    # Uncomment the following statement (or remove the method) to completely
    # disable the multilingual emails feature.
    # return super(*args, **options)

    buffer = ActiveSupport::SafeBuffer.new
    spacer = "\n#{'=' * 80}\n\n" if I18n.available_locales.size > 1
    locale = I18n.locale
    locales = I18n.available_locales.reject {|lcl| lcl == locale}

    locales.each do |locale|
      buffer << t('globals.mailer.localized_message_below', locale: locale)
      buffer << "\n"
    end

    locales.unshift(locale).each do |locale|
      I18n.locale = locale
      buffer << spacer << super(*args, **options)
    end
    I18n.locale = locale

    buffer
  end

end