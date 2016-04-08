class ComparisonsController < ApplicationController
  include Locatable

  def index
    @comparisons = Comparison.where(:is_draft.ne => true).order_by(:rank => 'asc')
    render layout: 'main'
  end

  def show
    @comparison = Comparison.find(params['id'])
    session[:last_comparison_id] = @comparison.id
    @variables = @comparison.variables
    @hospitals = @comparison.hospitals.sort_by { |h| h.distance_to @location }[0..9]
  end
end
