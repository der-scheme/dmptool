module RequirementsTemplatesHelper
  def referer_hash
    @referer_hash ||= session[:page_history][0] || {}
  end
end
