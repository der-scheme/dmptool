class UserSessionsController < ApplicationController

  before_action :return_to_last_locale, only: [:create, :destroy, :failure]

  def login
    if !params[:institution_id].blank?
      session['institution_id'] = params[:institution_id]
    elsif session['institution_id'].blank?
      redirect_to choose_institution_path, flash: {error: t('.no_institution_error')} and return
    end
    @institution = Institution.find(session[:institution_id])
    if !@institution.shib_domain.blank?
      #initiate shibboleth login sequence
      redirect_to OmniAuth::Strategies::Shibboleth.login_path_with_entity(
          Dmptool2::Application.shibboleth_host, @institution.shib_entity_id)
    else
      #just let the original form render
    end
  end

  def create
    redirect_to choose_institution_path if session[:institution_id].blank? and return
    auth = env["omniauth.auth"]
    user = nil
    begin
      user = User.from_omniauth(auth, session['institution_id'])
    rescue User::LoginException => ex
      msg = ex.to_s
      case ex.to_s
        when 'incomplete information from identity provider'
          msg = t('.incomplete_info_error')
        when 'multiple users with same email'
          msg = t('.duplicate_email_error')
        when 'user deactivated'
          msg = t('.account_deactivated_error')
        when 'authentication without user record'
          msg = t('.auth_wo_record_error')
      end
      redirect_to choose_institution_path, flash: { error: msg } and return
    end
    if auth[:provider] == 'shibboleth' && user.nil?
      redirect_to choose_institution_path, flash: { error: t('.incommon_error')} and return
    end
    if user.nil? || !user.active?
     redirect_to choose_institution_path, flash: { error: t('.incorrect_credentials_error')} and return
    end
    session[:user_id] = user.id
    session[:login_method] = auth[:provider]

    if user.first_name.blank? || user.last_name.blank? || user.prefs.blank?
      redirect_to edit_user_path(user), flash: {error: t('.incomplete_info_error')} and return
    else
      unless session[:return_to].blank?
        r = session[:return_to]
        session.delete(:return_to)
        redirect_to r and return
      end
      redirect_to dashboard_path and return
    end
  end

  def failure
    redirect_to choose_institution_path, flash: { error: t('.error_message')}
  end

  def destroy
    reset_session
    session[:user_id]
    redirect_to root_path, notice: t('.notice')
  end

  #allow choosing the institution before logging in.
  def institution
     @inst_list = InstitutionsController.institution_select_list
  end

  #email username from email address -- get the form, post the submission
  def username_reminder
    if request.post?
      email = params[:email]
      if email.present? && email.match(/^.+\@.+\..+$/)
        users =  User.where(email: email).includes(:authentications).where(active: true).where(authentications: {:provider => 'ldap'})
        if users.length > 0
          uid = users.first.authentications.first.uid
          UsersMailer.username_reminder(uid, email).deliver
          flash[:notice] = t('.success_notice', email: email)
          redirect_to login_path
        else
          flash[:error] = t('.no_such_user_error', email: email)
          redirect_to(:action => 'username_reminder', email: email) and return
        end
      else
        flash[:error] = t('.invalid_email_error')
        redirect_to(:action => 'username_reminder', email: email) and return
      end
    end
  end

  #reset the password for an email address and mail it -- get is the form, post the submission
  def password_reset
    if request.post?
      email = params[:email]
      if email.present?
        ldap_user = nil
        dmp_user = false
        if email.match(/^.+\@.+\..+$/)
          users =  User.where(email: email).where(active: true)
          begin
            ldap_user = Ldap_User.find_by_email(email)
            dmp_user = ldap_user.objectclass.include?('dmpUser')
          rescue Exception => ex
          end
        else
          users =  User.where(active: true).where(login_id: email)
          begin
            ldap_user = Ldap_User.find_by_id(email)
            dmp_user = ldap_user.objectclass.include?('dmpUser')
          rescue Exception => ex
          end
        end
        if users.length > 0 && !ldap_user.nil? && dmp_user
          user = users.first
          email = user.email
          token = user.ensure_token
          reset_url = complete_password_reset_url(:id => user.id, :token => token, :protocol => 'https')
          UsersMailer.password_reset(user.login_id, email, reset_url).deliver

          flash[:notice] = t('.success_notice', email: email)
          redirect_to login_path and return
        elsif users.length < 1
          flash[:error] = t('.no_such_user_error', email: email)
          redirect_to(:action => 'password_reset', email: email) and return
        elsif ldap_user.nil?
          flash[:error] = t('.reset_shib_error')
          redirect_to(:action => 'password_reset', email: email) and return
        elsif dmp_user == false
          flash[:error] = t('.ldap_disabled_error')
          redirect_to(:action => 'password_reset', email: email) and return
        end
      else
        flash[:error] = t('.incomplete_info_error')
        redirect_to(:action => 'password_reset', email: email) and return
      end
    end
  end

  def complete_password_reset
    user_id = params[:id]
    token = params[:token]
    @user = User.find_by_id(user_id)
    unless @user && @user.token && @user.token_expiration
      flash[:error] = t('.no_token_error')
      redirect_to(root_path) and return
    end
    if @user.token_expiration < Time.now
      flash[:error] = t('.token_expired_error')
      redirect_to(:action => 'password_reset') and return
    end
    unless @user.token == token
      flash[:error] = t('.invalid_token_error')
      redirect_to(:action => 'password_reset') and return
    end


    if request.post?
      password = params[:password]
      password_confirmation = params[:password_confirmation]

      unless legal_password(password)
        flash[:error] = t('.illegal_password_error')
        redirect_to(complete_password_reset_path(:id => @user.id, :token => @user.token)) and return
      end

      unless password == password_confirmation
        flash[:error] = t('.wrong_confirmation_error')
        redirect_to(complete_password_reset_path(:id => @user.id, :token => @user.token)) and return
      end

      begin
        Ldap_User.find_by_email(@user.email).change_password(password)
      rescue Exception => ex
        flash[:error] = t('.ldap_error')
        redirect_to(complete_password_reset_path(:id => @user.id, :token => @user.token)) and return
      end

      @user.clear_token
      flash[:notice] = t('.success_notice')
      redirect_to login_path and return
    end
  end

  def legal_password(password)
    (8..30).include?(password.length) and password.match(/\d/) and password.match(/[A-Za-z]/)
  end

private

  ## Return the last locale chosen by the user.
  #
  # In case of a login method were the user is redirected to a statically
  # chosen URL we lose the info which locale they've chosen before.
  # We use our page history to look up the params that were used in previous
  # visits of the site, or (if the page history is empty) just rely one an
  # empty hash instead (which will yield a nil locale, implying fallback to
  # browser settings).

  def return_to_last_locale
    params[:locale] = session[:page_history].try(:first).try(:fetch, :locale, nil)
    set_locale
  end
end
