class HomeController < ApplicationController
  def home
    render layout: 'home'
  end

  def redirect
    redirect_to "/#{session[:language] || I18n.locale}"
  end
end