module RequirementsTemplatesHelper
  def activate_link_text(requirements_template)
    requirements_template.active? ?
        t('globals.template.details.action_deactivate') :
        t('globals.template.details.action_activate')
  end
	def display_status_text(requirements_template)
    requirements_template.active? ?
        t('globals.template.details.status_active') :
        t('globals.template.details.status_inactive')
  end
  def referer_hash
    @referer_hash ||= session[:page_history][0] || {}
  end
end
