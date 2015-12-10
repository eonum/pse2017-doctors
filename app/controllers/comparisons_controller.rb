class ComparisonsController < ApplicationController
  include Locatable

  def index
   @comparisons = Comparison.order_by(:rank => 'asc')
  end

  def show
    @comparison = Comparison.find(params['id'])
    @variables = @comparison.variables.order_by(:rank => 'asc')
    # TODO implement location based search: get nearest ten hospitals instead of first ten.
    # in a second step hospital_locations could also be included in the search
    @hospitals = @comparison.hospitals[0..9]
  end
end
