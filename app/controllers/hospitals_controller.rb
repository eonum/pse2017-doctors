class HospitalsController < ApplicationController
  include Locatable
  before_action :set_hospital, only: [:show, :field]

  # GET /admin/hospitals/1
  # GET /admin/hospitals/1.json
  def show
    @comparisons = Comparison.order_by(:rank => 'asc')

    @doctors = if session[:last_comparison_id].present?
                 @last_comparison = Comparison.find(session[:last_comparison_id])

                 if @last_comparison.doctor_fields.any?
                   Doctor.any_in(docfields: @last_comparison.doctor_fields)
                 else
                   Doctor.all
                 end
               else
                 Doctor.all
               end

    @doctors = @doctors.geo_near(@hospital.location).max_distance(10).to_a[0..29]
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
