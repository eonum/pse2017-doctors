class ComparisonsController < ApplicationController
  include Locatable

  def index
   @comparisons = Comparison.order_by(:rank => 'asc')
  end

  def show
    @comparison = Comparison.find(params['id'])
    @variables = @comparison.variables.order_by(:rank => 'asc')

    query_location = @location

    @hospitals = @comparison.hospitals.sort_by do |h|
      loc = h.hospital_locations.first
      if loc
        loc.distance_to query_location
      else
        Geocoder::Calculations.distance_between([0.0, 0.0], query_location)
      end
    end

    @hospitals = @hospitals[0..9]
  end
end
