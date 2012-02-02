
Warden::Manager.after_set_user do |user, warden, options|
  return unless user

  scope = options[:scope]

  if user.status == "deleted"
    user.forget_me! if user.respond_to?(:forget_me!)
    warden.logout
    throw(:warden, :message => "user account is deleted", :scope => scope)
  end
end

