module ResourceTemplatesHelper
  def activate_link_text(resource_template)
    resource_template.active? ?
        t('globals.helpers.template.details.action_deactivate') :
        t('globals.helpers.template.details.action_activate')
  end
	def display_status_text(resource_template)
    resource_template.active? ?
        t('globals.helpers.template.details.status_active') :
        t('globals.helpers.template.details.status_inactive')
  end
end
