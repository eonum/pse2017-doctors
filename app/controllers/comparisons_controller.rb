class ComparisonsController < ApplicationController
  include Locatable

  def index
   @comparisons = Comparison.order_by(:rank => 'asc')
  end

  def show
    @comparison = Comparison.find(params['id'])
    @variables = @comparison.variables
    @hospitals = @comparison.hospitals.sort_by { |h| h.distance_to @location }[0..9]
  end
end
