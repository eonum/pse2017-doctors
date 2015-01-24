class DoctorsController < ApplicationController
  include Locatable

  def index
    @doctors = Doctor.near(@location).limit(default_return_count)
  end

  def show
    @doctor = Doctor.find_by(doc_id: params['id'])
  end
end

