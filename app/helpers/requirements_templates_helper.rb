module RequirementsTemplatesHelper
  def activate_link_text(requirements_template)
    requirements_template.active? ? 'Deactivate' : 'Activate'
  end
	def display_status_text(requirements_template)
    requirements_template.active? ? 'Active' : 'Inactive'
  end
  def referer_hash
    @referer_hash ||= session[:page_history][0] || {}
  end
end
