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
  def new
    @field = {'2011' => '', '2012' => '', '2013' => ''}
  end

  # GET /admin/fields/1/edit
  def edit
  end

  # POST /admin/fields
  # POST /admin/fields.json
  def create
    @hospital[params[:id]] = params[:field]

    respond_to do |format|
      if @hospital.save
        format.html { redirect_to admin_hospital_field_path(@hospital, params[:id]), notice: 'Field was successfully created.' }
        format.json { render :show, status: :created, location: @admin_field }
      else
        format.html { render :new }
        format.json { render json: @hospital.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/fields/1
  # PATCH/PUT /admin/fields/1.json
  def update
    @hospital[params[:id]] = params[:field]
    respond_to do |format|
      if @hospital.save
        format.html { redirect_to @admin_field, notice: 'Field was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_field }
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
