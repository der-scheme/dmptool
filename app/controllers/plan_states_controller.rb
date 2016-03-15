class PlanStatesController < ApplicationController
before_action :require_login
before_action :set_plan, only: [:approved, :rejected, :submitted, :committed, :reviewed]

  def approved
    plan_state = PlanState.find(@plan.current_plan_state_id).state
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      review_plan_state(:approved) if (plan_state == :submitted || plan_state == :approved)
    else
      flash[:error] =  t('.permission_error')
      redirect_to perform_review_plan_path(@plan)
    end
  end

  #for informal review
  def reviewed
    plan_state = PlanState.find(@plan.current_plan_state_id).state
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      if (plan_state == :submitted || plan_state == :approved || plan_state == :reviewed)
        review_plan_state(:reviewed) and return
      else
        flash[:error] =  t('.state_error')
        redirect_to perform_review_plan_path(@plan) and return
      end
    else
      flash[:error] =  t('.permission_error')
      redirect_to perform_review_plan_path(@plan) and return
    end
  end

  def rejected(plan_id)
    @plan = Plan.find(@plan_id)
    plan_state = PlanState.find(@plan.current_plan_state_id).state
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      review_plan_state(:rejected) if (plan_state == :submitted || plan_state == :rejected)
    else
      flash[:error] =  t('.permission_error')
      redirect_to perform_review_plan_path(@plan)
    end
  end

  def reject_with_comments
    @plan_id = params[:comment][:plan_id]
    @comment = Comment.new(comment_params)
    @comment.save
    rejected(@plan_id)
  end

  def submitted
    unless @plan.nil?
      requirements_template = RequirementsTemplate.find(@plan.requirements_template_id)
      requirements = requirements_template.requirements
      count = requirements.where(obligation: :mandatory).count
      @responses = Requirement.requirements_with_mandatory_obligation(@plan.id, requirements_template.id)
      if @responses.count == count
        create_plan_state(:submitted)
      else
        flash[:error] =  t('.incomplete_error')
        redirect_to preview_plan_path(@plan)
      end
    end
  end

  def committed
    @responses = Array.new
    unless @plan.nil?
      requirements_template = RequirementsTemplate.find(@plan.requirements_template_id)
      requirements = requirements_template.requirements
      count = requirements.where(obligation: :mandatory).count
      @responses = Requirement.requirements_with_mandatory_obligation(@plan.id, requirements_template.id)
      if @responses.count == count
        create_plan_state(:committed)
      else
        flash[:error] =  t('.incomplete_error')
        redirect_to preview_plan_path(@plan)
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:plan_id])
    end

    def create_plan_state(state)
      unless @plan.current_plan_state == state
        plan_state = PlanState.create( plan_id: @plan.id, state: state, user_id: current_user.id)
        @plan.current_plan_state_id = plan_state.id
        redirect_to preview_plan_path(@plan), notice: t('helpers.controller.plan_state.state_changed', state: state)
      else
        redirect_to preview_plan_path(@plan), alert: t('helpers.controller.plan_state.already_in_state', state: state)
      end
    end

    def review_plan_state(state)
      unless @plan.current_plan_state == state
        plan_state = PlanState.create( plan_id: @plan.id, state: state, user_id: current_user.id)
        @plan.current_plan_state_id = plan_state.id
        redirect_to perform_review_plan_path(@plan), notice: t('helpers.controller.plan_state.state_changed', state: state)
      else
        redirect_to perform_review_plan_path(@plan), alert: t('helpers.controller.plan_state.already_in_state', state: state)
      end
    end

    def comment_params
      params.require(:comment).permit(:user_id, :plan_id, :value, :visibility, :comment_type)
    end

end
