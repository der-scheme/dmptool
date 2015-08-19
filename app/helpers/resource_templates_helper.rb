module ResourceTemplatesHelper
  def activate_link_text(resource_template)
    resource_template.active? ? t('.deactivate_button') : t('.activate_button')
  end
	def display_status_text(resource_template)
    resource_template.active? ? t('.active') : t('.inactive')
  end
end
