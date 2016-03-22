class ApplicationController < ActionController::Base
  include Sortable::Controller

  ROLES =
      {   :dmp_admin              => Role::DMP_ADMIN,
          :resource_editor        => Role::RESOURCE_EDITOR,
          :template_editor        => Role::TEMPLATE_EDITOR,
          :institutional_reviewer => Role::INSTITUTIONAL_REVIEWER,
          :institutional_admin    => Role::INSTITUTIONAL_ADMIN}

  after_action :update_history

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # enable_authorization

  helper_method :current_user, :safe_has_role?, :require_login, :user_role_in?,
                :t_attr, :translate_attribute, :t_enum, :translate_enum

  before_action :set_locale

  protected

    def set_locale
      I18n.locale = params[:locale] ||
          extract_locale_from_accept_language_header || I18n.default_locale
    end

    def default_url_options(options = {})
      {locale: params[:locale]}.merge options
    end

    def current_user
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    end

    def require_login
      if session[:user_id].blank?
        flash[:error] = t('helpers.controller.application.require_login.generic')
        session[:return_to] = request.original_url
        redirect_to choose_institution_path and return
      elsif controller_name != 'users' && (current_user.first_name.blank? || current_user.last_name.blank?)
        flash[:error] = t('helpers.controller.application.require_login.identity')
        redirect_to edit_user_path(session[:user_id])
      end
    end

    #require that a user is logged out
    def require_logout
      if session && !session[:user_id].blank?
        flash[:error] = t('helpers.controller.application.require_logout')
        redirect_to dashboard_path and return
      end
    end

    #checks you're an editor for customizations in general
    def check_customization_editor
      unless user_role_in?(:dmp_admin, :resource_editor, :institutional_admin)
        flash[:error] = t('helpers.controller.application.generic.permission_denied')
        redirect_to dashboard_path and return
      end
    end

    #checks the user is allowed to edit page in this customization context
    #in this case a customization must be a container for other customizations (#6 and #8)
    #and params[:id] is the number of the container customization.
    def check_editor_for_this_customization
      if params[:id].blank?
        flash[:error] = t('helpers.controller.application.check_editor_for_this_customization.missing_id')
        redirect_to resource_contexts_path and return
      end
      cust = ResourceContext.find_by_id(params[:id])
      level = cust.resource_level unless cust.nil?
      if cust.nil? || !level['Container'] #this isn't a container customization
        flash[:error] = t('helpers.controller.application.check_editor_for_this_customization.incorrect_customization')
        redirect_to resource_contexts_path and return
      end
      # the user doesn't have permissions on this institution and isn't a DMP admin
      if !current_user.institution.subtree_ids.include?(cust.institution_id) && !user_role_in?(:dmp_admin)
        flash[:error] = t('helpers.controller.application.generic.permission_denied')
        redirect_to dashboard_path and return
      end
    end

    def safe_has_role?(role)
      #this returns whether a user has a role, but does it safely.  If no user is logged in
      #then it returns false by default.  Will work with either number or more readable role name.
      return false if current_user.nil?
      if role.class == Fixnum || (role.class == String && role.match(/^[-+]?[1-9]([0-9]*)?$/) )
        current_user.has_role?(role)
      else
        current_user.has_role_name?(role)
      end
    end

    # a shorter method to see if user has any of these roles and returns true if has any of the roles passed in.
    # pass in any of these
    # :dmp_admin, :resource_editor, :template_editor,  :institutional_reviewer, :institutional_admin
    def user_role_in?(*roles)
      if (roles - ROLES.keys).length > 0
        raise "role not defined in application_controller#user_role_in?.  It's likely you've mistyped a role symbol."
      end
      return false if current_user.nil?
      r = roles.map {|i| ROLES[i]}
      matching_roles = current_user.roles.pluck(:id) & r
      return true if matching_roles.length > 0
      return false
    end

    def check_admin_access
      unless user_role_in?(:dmp_admin, :resource_editor, :template_editor, :institutional_reviewer, :institutional_reviewer)
        if current_user
          flash[:error] = t('helpers.controller.application.generic.access_denied')
        else
          flash[:error] = t('helpers.controller.application.generic.login_needed')
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_institution_admin_access
      unless user_role_in?(:dmp_admin, :institutional_admin)
        if current_user
          flash[:error] = t('helpers.controller.application.generic.access_denied')
        else
          flash[:error] = t('helpers.controller.application.generic.login_needed')
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_dmp_admin_access
      unless user_role_in?(:dmp_admin)
        if current_user
          flash[:error] = t('helpers.controller.application.generic.access_denied')
        else
          flash[:error] = t('helpers.controller.application.generic.login_needed')
        end
        redirect_to root_url # halts request cycle
      end
    end



    def check_DMPTemplate_editor_access
      unless user_role_in?(:dmp_admin, :institutional_admin, :template_editor, :resource_editor)
        if current_user
          flash[:error] = t('helpers.controller.application.generic.access_denied')
        else
          flash[:error] = t('helpers.controller.application.generic.login_needed')
        end
        redirect_to root_url # halts request cycle
      end
    end

    def view_DMP_index_permission
      unless user_role_in?(:dmp_admin, :institutional_admin, :template_editor, :resource_editor)
        if current_user
          flash[:error] = t('helpers.controller.application.generic.access_denied')
        else
          flash[:error] = t('helpers.controller.application.generic.login_needed')
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_resource_editor_access
      unless user_role_in?(:dmp_admin, :institutional_admin, :resource_editor)
        if current_user
          flash[:error] = t('helpers.controller.application.generic.access_denied')
        else
          flash[:error] = t('helpers.controller.application.generic.login_needed')
        end
        redirect_to root_url # halts request cycle
      end
    end

    def sanitize_for_filename(filename)
      ActiveSupport::Inflector.transliterate filename.downcase.gsub(/[\\\/?:*"><|]+/,"_").gsub(/\s/,"_")
    end

    def make_institution_dropdown_list
      @inst_list = InstitutionsController.institution_select_list
    end

    def process_requirements_template(requirement_templates)

      institutions = get_base_institution_buckets(requirement_templates)

      return {} if institutions.blank?

      #this creates a hash with institutions as keys and requirements_templates as values like below
      # { <institution_object1> => [<requirements_template_1>, <requirements_template_2> ],
      #     <institution_object2> => [<requirements_template_1>] }
      # This works slightly different between institutional admins and WAS admins since the tree
      # is not the same.
      rt_tree = Hash[institutions.map{|i| [i, requirement_templates.where(institution_id: i.subtree_ids)] }]

      #this transforms the hash so that there is a possible 2-level heirarchy like institution => [req_template1, req_template2] or
      # req_template => nil, see example below:
      # { <institution_object1> => [<requirements_template_1>, <requirements_template_2> ],
      #     <requirements_template_1> => nil }
      @rt_tree = Hash[rt_tree.map{|i| (i[1].length == 1 ? [i[1].first, nil] : i )} ]


      # sort out for institutional admins so that their institution templates appear on first level if any
      #if !valid_buckets.nil? && @rt_tree.has_key?(current_user.institution)
      #  templates = @rt_tree.delete(current_user.institution)
      #  templates.each do |t|
      #    @rt_tree[t] = nil
      #  end
      #end

      #sort first level items by name (both institutions and requirements templates)
      @rt_tree = Hash[@rt_tree.sort{|x,y| x[0].name.downcase <=> y[0].name.downcase}]

      #sort any second level items by name (just requirements templates within an institution)
      @rt_tree.each do |k, v|
        v.sort!{|x, y| x.name.downcase <=> y.name.downcase} unless v.nil?
      end

      #put all results at top level if only one institution has results
      if @rt_tree.length == 1 && !@rt_tree.first[1].nil?
        @rt_tree = Hash[ @rt_tree.first[1].map{|i| [i, nil]} ]
      end
    end

  private
    def get_base_institution_buckets(requirements_templates)
      insts = Institution.where(id: requirements_templates.pluck(:institution_id)).distinct
      least_depth = 1000
      insts.each do |i|
        least_depth = i.depth if i.depth < least_depth
        break if least_depth == 0
      end
      return {} if least_depth == 1000
      inst_ids = insts.map { |i|  (i.ancestor_ids + [ i.id])[least_depth] }

      Institution.find(inst_ids)
    end

    def extract_locale_from_accept_language_header
      locale = request.env['HTTP_ACCEPT_LANGUAGE']
          .try(:scan, /^[a-z]{2}(?:-[A-Z]{2})?/)
          .try(:first).try(:to_sym)
      locale if locale.in?(Rails.application.config.i18n.available_locales)
    end

    ## Stores the current #params in the #session hash.
    #
    # Note that unlike the previous functionality (implemented in
    # ApplicationHelper#set_page_history), which stored entire URLs, this one
    # stores the parameters that can be used to build URLs using #url_for.
    #
    # This saves later computation time, as the only current purpose is to
    # later retrieve controller and action names, and also works around a Rails
    # bug we encountered when implementing i18n.

    def update_history
      return unless status == 200
      history = (session[:page_history] ||= [])
      history.unshift(params) unless params == history.first
      history.slice!(4, 42)   # delete some entries if history.size > 4
    end

  ##
  # Return a human readable translation for the given enum (or boolean)
  # attribute value.
  #
  # The +value+ parameter can be omitted with the following semantics.
  # 1. If +model+ is an instance of ActiveRecord::Base, the value of the
  #    +attribute+ will be used.
  # 2. Otherwise, a deduction of the actual model class and lookup of its
  #    corresponding attribute is attempted. If the contents of the +limit+
  #    parameter is an array, its first entry is chosen.
  # 3. The fallback value is always +false+.

  def translate_enum(model, attribute, value = nil)
    case model
    when Symbol
      model_scope = model
      model_class = model.to_s.classify.constantize
    when Class
      model_scope = model.model_name.i18n_key
      model_class = model
    when ActiveRecord::Base
      model_class = model.class
      model_scope = model_class.model_name.i18n_key
    else
      model = model.to_s
      model_scope = model.to_sym
      model_class = model.classify.constantize
    end

    value = model.try(:attributes)
        .try(:[], attribute.to_s)     unless value || value == false
    value = model_class.columns_hash[attribute.to_s]
        .limit.try(:first) || false   unless value || value == false

    value = value.to_s.to_sym unless value.is_a? Symbol

    translate(value, scope: [:enum, model_scope, attribute])
  end
  alias_method :t_enum, :translate_enum
  alias_method :translate_attribute, :translate_enum
  alias_method :t_attr, :translate_attribute
end
