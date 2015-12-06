class HomeController < ApplicationController
  def home
    render layout: 'empty'
  end

  def about
    render layout: 'empty'
  end

  def help
    render layout: 'empty'
  end

  def redirect
    redirect_to "/#{session[:language] || I18n.locale}"
  end
end