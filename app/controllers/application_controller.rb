require_relative '../models/service/search.rb'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Mongoid::Errors::DocumentNotFound, with: :error_method

  before_action :set_language
  before_action :set_search

  def default_url_options
    { :locale => I18n.locale }
  end

  private

    def set_search
      @search = (params['q'] and not params['q'].blank?) ? Search.search(params['q']) : []
    end

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
