module UsersHelper
  def password_label user
    user.new_record? ? t('.password') : t('.new_password')
  end

end