class CustomizationsController < ApplicationController

  before_action :require_login
  before_action :check_customization_editor, only: [:show]
  before_action :check_editor_for_this_customization, only: [:show]

  def show
    # information to display the repetitive tabs
    # name is tab name
    # partial is the partial to display
    # scope is the scope to use from the requirements table
    # requirement_only means that this item can only be displayed when attached to a
    # specific requirement -- it shouldn't be displayed if erroneously attached as global or template-level resource
    # the suggested responses and example responses can only be displayed for a specific requirement
    @tabs =
      [
        {name: t('.guidance_tab'),           button_text: t('.add_guidance_button'),           partial: 'guidance_item',       scope: :guidance,           requirement_only: false},
        {name: t('.links_tab'),              button_text: t('.add_links_button'),              partial: 'actionable_url_item', scope: :actionable_url,     requirement_only: false},
        {name: t('.suggested_response_tab'), button_text: t('.add_suggested_response_button'), partial: 'guidance_item',       scope: :suggested_response, requirement_only: true},
        {name: t('.example_response_tab'),   button_text: t('.add_example_response_button'),   partial: 'guidance_item',       scope: :example_response,   requirement_only: true }
      ]  #right now all but links are displayed with the guidance partial since they're the same

    # :id is customization id and :requirement_id
    @customization = ResourceContext.find(params[:id])
    @resource_context = @customization
    unless @customization.resource_id.blank?
      flash[:error] = t('.invalid_customization_error')
      redirect_to resource_contexts_path and return
    end
    @requirements_template = @customization.requirements_template
    @requirements = @requirements_template.requirements
    if params[:requirement_id].blank?
      requirement = @requirements_template.first_question
      if requirement.nil?
        flash[:error] = t('.no_requirements_error')
        redirect_to resource_contexts_path and return
      end
      params[:requirement_id] = requirement.id.to_s
    end

    @requirement = Requirement.find(params[:requirement_id])
    @institution = @customization.institution unless @customization.institution_id.nil?


    suggested_responses = @requirement.resources(@customization.institution_id).suggested_response.count
    example_responses = @requirement.resources(@customization.institution_id).example_response.count

    #can only show suggested responses or example responses when one has an item and the other doesn't
    if suggested_responses > 0
      @tabs.delete_at(3)
    elsif example_responses > 0
      @tabs.delete_at(2)
    end

    ###############################################
    #params for adding another resource
    @requirement_id = @requirement.id
    @template_id = @requirements_template.id
    @customization_id = @customization.id
    @resource_level = "requirement"
    ##############################################

  end

end
