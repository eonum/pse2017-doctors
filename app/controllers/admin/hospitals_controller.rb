class Admin::HospitalsController < Admin::AdminController
  before_action :set_hospital, only: [:show, :edit, :update, :destroy, :create_location, :geolocate]
  before_action :set_cantons, only: [:new, :edit, :update, :destroy, :create_location, :geolocate]

  # GET /admin/hospitals
  # GET /admin/hospitals.json
  def index
    @hospitals = Hospital.all

    query = escape_query(params[:q])
    query = /#{Regexp.escape(query)}/i
    @hospitals = Hospital.where({'name'=> query}).order_by([[ :rank, :asc ]])
    @hospitals = @hospitals.paginate(:page => params[:page], :per_page => 10)
  end

  # GET /admin/hospitals/1
  # GET /admin/hospitals/1.json
  def show
    @variables_qip = Variable.where({ 'variable_sets' => { '$in' => ['qip'] }})
    @variables_kzp = Variable.where({ 'variable_sets' => { '$in' => ['kzp'] }})
  end

  def create_location
    @location = HospitalLocation.new
    @location.name = @hospital.name
    @location.address = "#{@hospital.address1}, #{@hospital.address2}"
    @location.hospital_id = @hospital.id
    @location.canton = @hospital.canton
    @location.location = @hospital.location
    @location.title = ''
    @location.doc_id = Random.rand(10000)

    if @location.save
      redirect_to :back, notice: 'Hauptsitz für dieses Spital wurde erfolgreich erstellt.'
    else
      redirect_to :back, alert: "Fehler beim Erstellen des Hauptsitzes für dieses Spital. #{@location.errors.full_messages.each{|msg| msg}}"
    end

  end

  def geolocate
    location = Geocoder.coordinates(@hospital.full_address)
    location = Geocoder.coordinates(@hospital.address2) if location == nil
    location = Geocoder.coordinates(@hospital.name) if location == nil
    @hospital.location = [location[1], location[0]]
    if @hospital.save
      redirect_to :back, notice: 'Erfolgreich neu lokalisiert.'
    else
      redirect_to :back, alert: "Fehler bei der Lokalisation dieses Spitals. #{@hospital.errors.full_messages.each{|msg| msg}}"
    end
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


    @doctors= Doctor.all

    # Never trust parameters from the scary internet, only allow the white list through.
    def hospital_params
      params.require(:hospital).permit(:name, :address1, :address2, :bfs_typo, :canton,:doctor_ids=>[])
    end
end
