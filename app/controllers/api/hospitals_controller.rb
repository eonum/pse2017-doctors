module Api
  class HospitalsController < ApplicationController

    def index
      hospitals = Hospital.near(default_location).order_by(:doc_id.asc).limit(10)
      render json: hospitals, status: 200
    end

    def show
      h = Hospital.find_by(doc_id: params['id'])
      render json: h, status: 200
    end

    private
      def default_location
        [46.950745, 7.440618]
      end
  end
end


