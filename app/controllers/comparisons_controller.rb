class ComparisonsController < ApplicationController
  include Locatable

  def index
   @comparisons = Comparison.all
  end

  def show
    @comparison = Comparison.find(params['id'])
  end
end
