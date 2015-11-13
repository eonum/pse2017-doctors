class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Mongoid::Errors::DocumentNotFound, with: :error_method

  before_action :set_language

  before_filter :update_sanitized_params, if: :devise_controller?

  def update_sanitized_params
    devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:username, :email, :password, :password_confirmation, :current_password)}
  end


  def default_url_options
    { :locale => I18n.locale }
  end

  def escape_query query
    return (query or '').gsub(/\\/, '\&\&').gsub(/'/, "''")
  end

  private
    def set_language
      I18n.locale = params['locale']
      session[:locale] = I18n.locale
    end

    def error_method
      respond_to do |format|
        format.html { render file: "#{Rails.root}/public/404", layout: false, status: 404 }
        format.json { render json: 'No such entry has been found!', status: 404 }
      end
    end

    def default_return_count
      10
    end

end
