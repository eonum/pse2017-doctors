class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Mongoid::Errors::DocumentNotFound, with: :error_method

  before_action :set_language

  def default_url_options
    { :locale => I18n.locale }
  end

  private
    def set_language
      I18n.locale = params['locale']
      session[:locale] = I18n.locale
    end

    def error_method
      render json: 'No such entry has been found!', status: 404
    end

    def default_return_count
      10
    end
end
