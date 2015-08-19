module RequirementsTemplatesHelper
  def activate_link_text(requirements_template)
    requirements_template.active? ? t('.deactivate_button') : t('.activate_button')
  end
	def display_status_text(requirements_template)
    requirements_template.active? ? t('.active') : t('.inactive')
  end
  def referer_action
    @referer_url = Rails.application.routes.recognize_path(URI((session[:page_history].blank? ? "": session[:page_history][0])).path)
  end
end
