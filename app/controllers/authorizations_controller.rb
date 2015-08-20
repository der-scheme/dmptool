class AuthorizationsController < ApplicationController

  before_action :require_login, except: [:pluralize_has]

	def add_authorization

    emails = params[:email].split(/,\s*/) unless params[:email] == ""
    @role_id = (params[:role_id]).to_i
    @role_name = params[:role_name]
    @path = '/' + params[:p]
    @invalid_emails = []
    @existing_emails = []
    @outside_emails = []
    @saved_emails = []

    emails.each do |email|
      @user_saved = false
      @user = User.find_by(email: email)
      if @user.nil?
        @invalid_emails << email
      else

        if (check_correct_permissions(@user.id, @role_id) ||  user_role_in?(:dmp_admin))

          @user_saved = true

          begin
            authorization = Authorization.create(role_id: @role_id, user_id: @user.id)
            authorization.save!
          rescue ActiveRecord::RecordNotUnique
            @existing_emails << email
            @user_saved = false
          end

        else
          @outside_emails << email
        end

        @saved_emails << email if @user_saved

      end
    end

    respond_to do |format|

      @messages = []

      if !@invalid_emails.empty?
        @messages << t('.not_found_message', emails: @invalid_emails.join(', '))
      end

      if !@existing_emails.empty?
        @messages << t('.existing_message', emails: @existing_emails.join(', '))
      end

      if !@outside_emails.empty?
        @messages << t('.foreign_message', emails: @outside_emails.join(', '))
      end

      if !@saved_emails.empty?
        @messages << t('.success_notice', emails: @saved_emails.join(', '))
        flash.now[:notice] = @messages.join ' '
      else
        flash.now[:error] = @messages.join ' '
      end


      format.js { render action: 'add_authorization' }
      return
    end

  end


  def remove_authorization
    @path = '/' + params[:p]
    @role_id = (params[:role_id]).to_i
    if check_correct_permissions( params[:user_id], @role_id )
      @authorization = Authorization.where(role_id: @role_id , user_id: params[:user_id] )
      @authorization_id = @authorization.pluck(:id)
      @authorization.delete_all
      redirect_to @path, notice: t('.success_notice')
    else
      flash[:error] = t('.not_allowed_message')
      redirect_to @path and return
    end
    return
  end

  def add_role_autocomplete
    u_name, u_id = nil, nil
    params.each do |k,v|
      u_name = v if k.end_with?('_name')
      u_id = v if k.end_with?('_id')
    end
    role_number = params[:role_number].to_i
    item_description = params[:item_description]

    if u_name.blank?
      flash[:error] = t('.blank_name_message', role: item_description)
      redirect_to :back and return
    end
    if !u_id.blank?
      user = User.find(u_id)
    else
      first, last = u_name.split(" ", 2)
      if first.nil? || last.nil?
        flash[:error] = t('.incomplete_message')
        redirect_to :back and return
      end
      users = User.where("first_name = ? and last_name = ?", first, last)
      if users.length > 1
        flash[:error] = t('.ambiguous_message')
        redirect_to :back and return
      end
      if users.length < 1
        flash[:error] = t('.not_found_message')
        redirect_to :back and return
      end
      user = users.first
    end
    if user.roles.map{|i| i.id}.include?(role_number)
      flash[:error] = t('.already_has_role_message', role: item_description)
      redirect_to :back and return
    end
    if !check_correct_permissions(user.id, role_number)
      flash[:error] = t('.not_allowed_message')
      redirect_to :back  and return
    end
    authorization = Authorization.create(role_id: role_number, user_id: user.id)
    authorization.save!
    redirect_to :back, notice: t('.success_notice', user: user.full_name, role: item_description)
  end

  def add_authorization_manage_users
     @role_ids = params[:role_ids] ||= []  #"role_ids"=>["1", "2", "3"]
    u_name, u_id = nil, nil
    params.each do |k,v|
      u_name = v if k.end_with?('_name')
      u_id = v if k.end_with?('_id')
    end
    role_number = params[:role_number].to_i
    #item_description = params[:item_description]

    if u_name.blank?
      flash[:error] = t('.blank_name_message')
      redirect_to :back and return
    end
    if !u_id.blank?
      user = User.find(u_id)
    else
      first, last = u_name.split(" ", 2)
      if first.nil? || last.nil?
        flash[:error] = t('.incomplete_message')
        redirect_to :back and return
      end
      users = User.where("first_name = ? and last_name = ?", first, last)
      if users.length > 1
        flash[:error] = t('.ambiguous_message')
        redirect_to :back and return
      end
      if users.length < 1
        flash[:error] = t('.not_found_message')
        redirect_to :back and return
      end
      user = users.first
    end
     unless (current_user.institution.subtree_ids.include?(user.institution.id) || user_role_in?(:dmp_admin))
      flash[:error] = t('.foreign_message')
      redirect_to :back and return
    end
    if user.has_any_role?
      flash[:error] = t('.already_has_role_message')
      redirect_to :back and return
    end
    if  @role_ids == []
      flash[:error] = t('.select_role_message')
      redirect_to :back and return
    end
     @role_ids.each do |role_id|
      role_id = role_id.to_i
      authorization = Authorization.create(role_id: role_id, user_id: user.id)
      authorization.save!
    end
    # unless check_correct_permissions(user.id, role_number)
    #   redirect_to :back, notice: "You do not have permission to assign this role" and return
    # end
    # authorization = Authorization.create(role_id: role_number, user_id: user.id)
    # authorization.save!
    #redirect_to :back, notice: "#{user.full_name} has been added as a #{item_description}"
    redirect_to :back, notice: t('.success_notice', user: user.full_name)
  end



  def check_correct_permissions(user_id, role_id)

    user = User.find(user_id)
    user_role_in?(:dmp_admin) ||
      ( user_role_in?(:institutional_admin) &&
        current_user.institution.subtree_ids.include?(user.institution_id)
      ) ||
      ( safe_has_role?(role_id) &&
        current_user.institution.subtree_ids.include?(user.institution_id)
      )
  end

end
