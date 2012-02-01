class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction, :with => :render_not_found
  end

  def render_not_found(exc)
    Rails.logger.error("404 error: #{exc}")
    Rails.logger.error(exc.backtrace.join("\n\t"))
    render :template => '/errors/404', :status => 404, :layout => nil
  end

  def render_error(exc)
    Rails.logger.error("500 error: #{exc}")
    Rails.logger.error(exc.backtrace.join("\n\t"))
    render :template => '/errors/500', :status => 500, :layout => nil
  end

  def not_found(url='')
    raise ActionController::RoutingError.new("Not Found (#{url})")
  end


  def authorize_admin!
    user_signed_in? && current_user.admin?
  end
end
