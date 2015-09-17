module UsersHelper
  def password_label user
    User.human_attribute_name(user.new_record? ? :password : :new_password)
  end

end