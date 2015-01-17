module Api
  class DoctorsController < ApplicationController

    def index
      doctors = Doctor.near(default_location).order_by(:doc_id.asc).limit(10)
      render json: doctors, status: 200
    end

    def show
      d = Doctor.find_by(doc_id: params['id'])
      render json: d, status: 200
    end

    private
      def default_location
        [46.950745, 7.440618]
      end
  end
end

