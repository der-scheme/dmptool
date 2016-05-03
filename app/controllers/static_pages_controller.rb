require 'rss'

class StaticPagesController < ApplicationController

  layout 'application', only: [:guidance, :contact]

  def orcid
    render(layout: nil)
  end

  def home
    @rss = Rails.cache.read('rss')
    @public_dmps = Plan.public_visibility.order(name: :asc).limit(3)
    if @rss.nil?
      begin
        rss_xml = open(APP_CONFIG['rss']).read
        @rss = RSS::Parser.parse(rss_xml, false).items.first(5)
        Rails.cache.write("rss", @rss, :expires_in => 15.minutes)
      rescue Exception => e
        logger.error("Caught exception: #{e}.")
      end
    end
  end

  def about
  end

  def community_resources
  end

  def data_management_guidance
  end

  def promote
  end

  def quickstartguide
  end

  def terms_of_use
  end

  def video
  end

  def partners
  end

  def help
  end

  def contact
    if request.post?
      if verify_recaptcha
        msg = []
        msg.push(t('.question_about_missing')) if params[:question_about].blank?
        msg.push(t('.name_missing')) if params[:name].blank?
        msg.push(t('.email_missing')) if params[:email].blank?
        msg.push(t('.message_missing')) if params[:message].blank?
        if !params[:email].blank? && !params[:email].match(/^\S+@\S+$/)
          msg.push(t('.email_invalid'))
        end
        if msg.length > 0
          flash[:error] = msg
          redirect_to contact_path(question_about: params['question_about'], name: params['name'],
                                   email: params['email'], message: params[:message]) and return
        end

        addl_to = (current_user ? [current_user.institution.contact_email] : [])
        all_emails = APP_CONFIG['feedback_email_to'] + addl_to
        all_emails.delete_if {|x| x.blank? } #delete any blank emails
        all_emails.each do |i|
          GenericMailer.contact_email(params, i).deliver
        end
        flash[:alert] = t('.success_message')
        redirect_to :back and return
      end
      redirect_to contact_path(question_about: params['question_about'], name: params['name'],
                          email: params['email'], message: params[:message]) and return
    end
  end

  def privacy
  end

  def guidance
    @public_templates = RequirementsTemplate.public_visibility.includes(:institution, :sample_plans, :additional_informations).active.current.public_visibility

    @scope1 = params[:scope1]
    @order_scope1 = params[:order_scope1]
    @s = params[:s]
    @e = params[:e]

    sortable :name,                     default: true,      model: RequirementsTemplate, inst_var: :public_templates, order_scope: :order_scope1
    sortable :institution_id,           nested: :full_name, model: RequirementsTemplate, inst_var: :public_templates, order_scope: :order_scope1
    sortable :additional_informations,  nested: :label,     model: RequirementsTemplate, inst_var: :public_templates, order_scope: :order_scope1
    sortable :sample_plans,             nested: :label,     model: RequirementsTemplate, inst_var: :public_templates, order_scope: :order_scope1

    case @scope1
      when "all"
        @public_templates = @public_templates.page(params[:public_guidance_page]).per(1000)
      else
        @public_templates = @public_templates.page(params[:public_guidance_page]).per(10)
    end

    unless params[:s].blank? || params[:e].blank?
      @public_templates = @public_templates.letter_range_by_institution(params[:s], params[:e])
    end

    if !params[:q].blank?
      @public_templates = @public_templates.search_terms(params[:q])
    end

    if current_user

      @scope2 = params[:scope2]
      @order_scope2 = params[:order_scope2]

      @institution_templates = current_user.institution.requirements_templates_deep.institutional_visibility.active.current.
              includes(:institution, :sample_plans, :additional_informations)

      sortable :name,                     default: true,      model: RequirementsTemplate, inst_var: :institution_templates, order_scope: :order_scope2
      sortable :institution_id,           nested: :full_name, model: RequirementsTemplate, inst_var: :institution_templates, order_scope: :order_scope2
      sortable :additional_informations,  nested: :label,     model: RequirementsTemplate, inst_var: :institution_templates, order_scope: :order_scope2
      sortable :sample_plans,             nested: :label,     model: RequirementsTemplate, inst_var: :institution_templates, order_scope: :order_scope2

      case @scope2
        when "all"
          @institution_templates = @institution_templates.page(params[:institutional_guidance_page]).per(1000)
        else
          @institution_templates = @institution_templates.page(params[:institutional_guidance_page]).per(10)
      end

    end

  end
end
