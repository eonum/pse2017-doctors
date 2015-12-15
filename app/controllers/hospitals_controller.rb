class HospitalsController < ApplicationController
  before_action :set_hospital, only: [:show, :field]

  # GET /admin/hospitals/1
  # GET /admin/hospitals/1.json
  def show
    render layout: 'empty'
  end

  def field
    @variable = Variable.find(params['varid'])
    render :json => { 'response' => @hospital[@variable['field_name']], 'hop_name' => @hospital.name, 'var_name' => @variable.localized_field('name', locale)}
  end

  private
    def set_hospital
      @hospital = Hospital.find(params[:id])
    end
end
