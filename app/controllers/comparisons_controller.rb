class ComparisonsController < ApplicationController
  include Locatable

  def index
   @comparisons = Comparison.all
  end

  def show
    @comparison = Comparison.find_by(code: params['id'])
  end
end
