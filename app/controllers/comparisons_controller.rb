class ComparisonsController < ApplicationController
  include Locatable

  def index
   @comparisons = Comparison.order_by(:rank => 'asc')
  end

  def show
    @comparison = Comparison.find(params['id'])
    # Unfortunately this is necessary because mongoid won't return has_many relations in the order stored in the database.
    @variables = []
    @comparison.variable_ids.each {|id| @variables << Variable.find(id)}

    @hospitals = @comparison.hospitals.sort_by { |h| h.distance_to @location }[0..9]
  end
end
