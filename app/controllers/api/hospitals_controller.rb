module Api
  class HospitalsController < ApplicationController

    def index
      @hospitals = Hospital.near(default_location).order_by(:doc_id.asc).limit(default_count)
    end

    def show
      @hospital = Hospital.find_by(doc_id: params['id'])
    end

    private

    def default_location
      [46.950745, 7.440618]
    end

    def default_count
      10
    end
  end
end


