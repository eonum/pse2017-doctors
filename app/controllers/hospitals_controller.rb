class HospitalsController < ApplicationController
  include Locatable

  def index
    @hospitals = Hospital.near(@location).limit(default_return_count)
  end

  def show
    @hospital = Hospital.find_by(doc_id: params['id'])
  end
end



