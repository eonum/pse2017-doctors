# Modify fields in hospitals
class Admin::FieldsController < Admin::AdminController
  before_action :set_hospital
  before_action :set_field, only: [:show, :edit, :update, :destroy]

  # GET /admin/fields
  # GET /admin/fields.json
  def index
    @variables = Variable.all
    @years = {'2011' => '', '2012' => '', '2013' => '', '2014' => ''}
  end

  # GET /admin/fields/1
  # GET /admin/fields/1.json
  def show
    @variable = Variable.find_by(field_name: params[:id])
  end

  # GET /admin/fields/new
  # params[:id] has always to be provided and the corresponding variable must exist
  def new
    @variable = Variable.find_by(field_name: params[:id])
    @field = ''
    if(@variable.is_time_series)
      @field = {'2011' => '', '2012' => '', '2013' => '', '2014' => ''}
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
        format.html { redirect_to admin_hospital_field_path(@hospital, params[:id]), notice: t('field_update') }
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
      format.html { redirect_to admin_hospital_fields_url, notice: t('field_destroyed') }
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
