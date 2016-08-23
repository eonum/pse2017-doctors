class Admin::HospitalLocationsController < Admin::AdminController
  before_action :set_hospital_location, only: [:show, :edit, :update, :destroy]

  # GET /admin/hospital_locations
  # GET /admin/hospital_locations.json
  def index
    query = escape_query(params[:q])
    query = /#{Regexp.escape(query)}/i
    @hospital_locations = HospitalLocation.where({'$or' => [{'title' => query},
                                             {'name'=> query}]})
                     .order_by([[ :rank, :asc ]])
    @hospital_locations = @hospital_locations.paginate(:page => params[:page], :per_page => 10)
  end

  # GET /admin/hospital_locations/new
  def new
    @hospital_location = HospitalLocation.new
  end

  # GET /admin/hospital_locations/1/edit
  def edit
  end

  # POST /admin/hospital_locations
  # POST /admin/hospital_locations.json
  def create
    @hospital_location = HospitalLocation.new(hospital_location_params)

    respond_to do |format|
      if @hospital_location.save
        format.html { redirect_to [:admin, @hospital_location], notice: t('hosp_loc_created') }
        format.json { render :show, status: :created, location: [:admin, @hospital_location] }
      else
        format.html { render :new }
        format.json { render json: @hospital_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/hospital_locations/1
  # PATCH/PUT /admin/hospital_locations/1.json
  def update
    respond_to do |format|
      if @hospital_location.update(hospital_location_params)
        format.html { redirect_to [:admin, @hospital_location], notice: t('hosp_loc_updated') }
        format.json { render :show, status: :ok, location: [:admin, @hospital_location] }
      else
        format.html { render :edit }
        format.json { render json: @hospital_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/hospital_locations/1
  # DELETE /admin/hospital_locations/1.json
  def destroy
    @hospital_location.destroy
    respond_to do |format|
      format.html { redirect_to admin_hospital_locations_url, notice: t('hosp_loc_destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hospital_location
      @hospital_location = HospitalLocation.find_by(doc_id: params['id'])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hospital_location_params
      params.require(:hospital_location).permit(:doc_id, :name, :title, :address, :email, :phone1, :phone2, :canton, :location, :hospital_id)
    end
end
