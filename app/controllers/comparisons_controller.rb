class ComparisonsController < ApplicationController
  include Locatable

  def index
   @comparisons = Comparison.all
  end

  def show
    @comparison = Comparison.find(params['id'])
    @variables = @comparison.variables
    # TODO implement location based search: get nearest ten hospitals instead of first ten.
    # in a second step hospital_locations could also be included in the search
    @hospitals = @comparison.hospitals[0..9]
  end
end
