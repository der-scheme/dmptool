module PlanEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_save :email_dmp_saved
  end

  # for these notifications:
  # [:dmp_owners_and_co][:committed] -- A DMP is completed (committed)
  # [:dmp_owners_and_co][:vis_change] -- A DMP's visibility has changed
  # [:dmp_owners_and_co][:submitted] -- A submitted DMP is approved or rejected
  # [:institutional_reviewers][:submitted] -- An Institutional DMP is approved or rejected
  # [:institutional_reviewers][:approved_rejected] -- An Institutional DMP is submitted for review
  def email_dmp_saved

    #[:dmp_owners_and_co][:vis_change] -- A DMP's visibility has changed
    # mail all owners and co-owners if the visibility has changed
    if changes[:visibility] &&  changes[:visibility][0] != changes[:visibility][1]
      users
        .select {|user| user[:prefs][:dmp_owners_and_co][:vis_change]}
        .each {|user| UsersMailer.plan_visibility_changed(user, self).deliver}
    end


    # if the current_plan_state hasn't changed value then return now and don't mess with any of the rest
    return unless changes[:current_plan_state_id]

    earlier_state = PlanState.find_or_initialize_by(id: changes[:current_plan_state_id][0])
    return if earlier_state.state == current_state.state

    # [:dmp_owners_and_co][:committed]  -- A DMP is completed (activated)
    if current_state.state == :committed
      users
        .select {|user| user[:prefs][:dmp_owners_and_co][:committed]}
        .each {|user| UsersMailer.plan_completed(user, self).deliver}

    # [:dmp_owners_and_co][:submitted] -- A submitted DMP is approved or rejected
    # [:institutional_reviewers][:approved_rejected] -- An Institutional DMP is approved or rejected
    elsif current_state.state.in?(:approved, :rejected, :reviewed)
      users
        .select {|user| user[:prefs][:dmp_owners_and_co][:submitted]}
        .each {|user| UsersMailer.plan_state_updated(user, self).deliver}

      owner.institution
        .users_in_and_above_inst_in_role(Role::INSTITUTIONAL_REVIEWER)
        .select {|user| user[:prefs][:institutional_reviewers][:approved_rejected]}
        .each do |user|
          UsersMailer.plan_state_updated(user, self, institutional: true).deliver
      end

    # [:institutional_reviewers][:submitted] -- An Institutional DMP is submitted for review
    elsif current_state.state == :submitted
      owner.institution
        .users_in_and_above_inst_in_role(Role::INSTITUTIONAL_REVIEWER)
        .select {|user| user[:prefs][:institutional_reviewers][:submitted]}
        .each {|user| UsersMailer.plan_under_review(user, self).deliver}
    end

  end
end