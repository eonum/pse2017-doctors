class HospitalsController < ApplicationController
  before_action :set_hospital, only: [:show, :field]

  # GET /admin/hospitals/1
  # GET /admin/hospitals/1.json
  def show
    @comparisons = Comparison.order_by(:rank => 'asc')
  end

  def field
    @variable = Variable.find_by(field_name: params[:field_name]) if params['field_name']
    @variable = Variable.find(params['varid']) if params['varid']
    render :json => { 'response' => @hospital[@variable['field_name']],
                      'hop_name' => @hospital.name, 'var_name' => @variable.localized_field('name', locale),
                      'field_name' => @variable.field_name}
  end

  private
    def set_hospital
      @hospital = Hospital.find(params[:id])
    end
end
