require_relative '../concerns/locatable.rb'

module Api
  class HospitalsController < ApplicationController
    include Locatable

    def index
      @hospitals = Hospital.near(@location).order_by(:doc_id.asc).limit(default_return_count)
    end

    def show
      @hospital = Hospital.find_by(doc_id: params['id'])
    end
  end
end


