# Modify fields in hospitals
class Admin::FieldsController < Admin::AdminController
  before_action :set_hospital
  before_action :set_field, only: [:show, :edit, :update, :destroy]

  # GET /admin/fields
  # GET /admin/fields.json
  def index
    @variables = Variable.all
    @years = {}
    @variables.each do |var|
      next if @hospital[var.field_name] == nil
      @hospital[var.field_name].each do |key, value|
        @years[key] = 1
      end
    end
  end

  # GET /admin/fields/1
  # GET /admin/fields/1.json
  def show
  end

  # GET /admin/fields/new
  # params[:id] has always to be provided and the corresponding variable must exist
  def new
    @variable = Variable.find_by(field_name: params[:id])
    @field = ''
    if(@variable.variable_sets.include? 'kzp')
      @field = {'2011' => '', '2012' => '', '2013' => ''}
    end
    if(@variable.variable_sets.include? 'qip')
      @field = {'2011' => {observed: 0, expected: 0, SMR: 0, num_cases:0},
                '2012' => {observed: 0, expected: 0, SMR: 0, num_cases:0},
                '2013' => {observed: 0, expected: 0, SMR: 0, num_cases:0}}
    end
  end

  # GET /admin/fields/1/edit
  # the corresponding variable must exist
  def edit
    @variable = Variable.find_by(field_name: params[:id])
  end

  # PATCH/PUT /admin/fields/1
  # PATCH/PUT /admin/fields/1.json
  def update
    @hospital[params[:id]] = params[:field]
    respond_to do |format|
      if @hospital.save
        format.html { redirect_to admin_hospital_field_path(@hospital, params[:id]), notice: 'Field was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_hospital_fields_path(@hospital, params[:id]) }
      else
        format.html { render :edit }
        format.json { render json: @hospital.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/fields/1
  # DELETE /admin/fields/1.json
  def destroy
    @hospital[params[:id]] = nil
    @hospital.save
    respond_to do |format|
      format.html { redirect_to admin_hospital_fields_url, notice: 'Field was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_field
      @field = @hospital[params[:id]]
      @name = params[:id]
    end

    def set_hospital
      @hospital = Hospital.find(params[:hospital_id])
    end
end
