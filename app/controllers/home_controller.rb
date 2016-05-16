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
    redirect_to comparison_url(Comparison.where(:is_draft.ne => true).order_by(:rank => 'asc').first)
  end
end