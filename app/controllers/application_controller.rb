class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def authorize_admin!
    user_signed_in? && current_user.admin?
  end
end
