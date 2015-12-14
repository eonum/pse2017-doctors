class HospitalsController < ApplicationController
  before_action :set_hospital, only: [:show]

  # GET /admin/hospitals/1
  # GET /admin/hospitals/1.json
  def show
    #render layout: 'empty'
  end

  private
    def set_hospital
      @hospital = Hospital.find(params[:id])
    end
end
