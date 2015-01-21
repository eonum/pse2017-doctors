module Api
  class DoctorsController < ApplicationController

    def index
      @doctors = Doctor.near(default_location).order_by(:doc_id.asc).limit(10)
    end

    def show
      @doctor = Doctor.find_by(doc_id: params['id'])
    end

    private
    def default_location
      [46.950745, 7.440618]
    end
  end
end
