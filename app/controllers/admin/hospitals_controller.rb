class Admin::HospitalsController < Admin::AdminController
  before_action :set_hospital, only: [:show, :edit, :update, :destroy]

  # GET /admin/hospitals
  # GET /admin/hospitals.json
  def index
    @hospitals = Hospital.all
  end

  # GET /admin/hospitals/1
  # GET /admin/hospitals/1.json
  def show
    @variables_qip = Variable.where({ 'variable_sets' => { '$in' => ['qip'] }})
    @variables_kzp = Variable.where({ 'variable_sets' => { '$in' => ['kzp'] }})
  end

  # GET /admin/hospitals/new
  def new
    @hospital = Hospital.new
  end

  # GET /admin/hospitals/1/edit
  def edit
  end

  # POST /admin/hospitals
  # POST /admin/hospitals.json
  def create
    @hospital = Hospital.new(hospital_params)

    respond_to do |format|
      if @hospital.save
        format.html { redirect_to [:admin, @hospital], notice: 'Hospital was successfully created.' }
        format.json { render :show, status: :created, location: [:admin, @hospital] }
      else
        format.html { render :new }
        format.json { render json: @hospital.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/hospitals/1
  # PATCH/PUT /admin/hospitals/1.json
  def update
    respond_to do |format|
      if @hospital.update(hospital_params)
        format.html { redirect_to [:admin, @hospital], notice: 'Hospital was successfully updated.' }
        format.json { render :show, status: :ok, location: [:admin, @hospital] }
      else
        format.html { render :edit }
        format.json { render json: @hospital.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/hospitals/1
  # DELETE /admin/hospitals/1.json
  def destroy
    @hospital.destroy
    respond_to do |format|
      format.html { redirect_to admin_hospitals_url, notice: 'Hospital was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hospital
      @hospital = Hospital.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hospital_params
      params.require(:hospital).permit(:name, :address1, :address2, :bfs_typo, :canton)
    end
end