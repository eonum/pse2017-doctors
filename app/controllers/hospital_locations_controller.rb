class HospitalLocationsController < ApplicationController
  include Locatable

  def index
    @hospitals = HospitalLocation.near(@location).limit(default_return_count)
  end

  def show
    @hospital = HospitalLocation.find_by(doc_id: params['id'])
  end
end



