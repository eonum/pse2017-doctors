class Admin::DoctorsController < Admin::AdminController
  before_action :set_doctor, only: [:show, :edit, :update, :destroy, :geolocate]
  before_action :set_fields, :set_cantons, only: [:new,  :edit, :update, :destroy, :geolocate]

  def index
    query = escape_query(params[:q])
    query = /#{Regexp.escape(query)}/i
    @doctors = Doctor.where(name: query).order_by([[ :rank, :asc ]])
    @doctors = @doctors.paginate(:page => params[:page], :per_page => 10)
  end

  def show
  end

  def new
    @doctor = Doctor.new
  end

  def edit


  end
  def create
    @doctor = Doctor.new(doctor_params)
    set_hospitals

    respond_to do |format|
      if @doctor.save
        format.html { redirect_to [:admin, @doctor], notice: "#{@doctor.name} wurde erfolgreich erstellt." }
        format.json { render :show, status: :created, location: [:admin, @doctor] }
      else
        format.html { render :new }
        format.json { render json: @doctor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @doctor = Doctor.find(params[:id])
    set_hospitals

    respond_to do |format|
      if @doctor.update(doctor_params)
        format.html { redirect_to [:admin, @doctor], notice: "#{@doctor.name} wurde erfolgreich geändert." }
        format.json { render :show, status: :ok, location: [:admin, @doctor] }
      else
        format.html { render :edit }
        format.json { render json: @doctor.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @doctor.destroy
    respond_to do |format|
      format.html { redirect_to admin_doctors_url, notice: "#{@doctor.name} wurde erfolgreich gelöscht." }
      format.json { head :no_content }
    end
  end

  def geolocate
    location = Geocoder.coordinates(@doctor.address)
    @doctor.location = [location[1], location[0]]
    if @doctor.save
      redirect_to :back, notice: t('relocated')
    else
      redirect_to :back, alert: t('error_locating')+" #{@doctor.errors.full_messages.each{|msg| msg}}"
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_doctor
    @doctor = Doctor.find(params['id'])
  end


    # Never trust parameters from the scary internet, only allow the white list through.
  def doctor_params
    p = params.require(:doctor).permit(:name, :title, :address, :email, :website, :phone1, :phone2, :canton, :docfields, :location,:hospital_ids=>[])
    p[:docfields] = p[:docfields].split(',').map(&:strip) if p[:docfields]
    # assume doctor no longer has connected hospitals, if no hospital_ids were given
    if params['doctor']['hospital_ids'].nil?
      p[:hospital_ids] = []
    end
    p
  end

  def set_hospitals
    return if params['doctor']['hospital_ids'].nil?
    @doctor.hospital_ids = params['doctor']['hospital_ids'].map {|hospital_id|  BSON::ObjectId.from_string(hospital_id)}
  end

  def set_fields
    @fields = ['Acupuncture', 'Aestetic Surgeons', 'Allergologists', 'Anaesthesiologits', 'Angiologists', 'Anthroposoph. Medicine', 'Cardiologists', 'Child Psychiatrists',
               'Dentists', 'Dermatologits', 'Diabetologists', 'Endocrinologists', 'Forensic Medicine', 'Gastroenterologists', 'Geriatrists', 'Gynaecologists',
               'General med.Practioner', 'Haematologists', 'Hand Surgery', 'Homeopathy', 'Infectiologists', 'Internists', 'Manual Medicine', 'Maxillo-Facial-Surgery',
               'Nephrologists', 'Neurologists', 'Obstetrics', 'Occupational Medicine', 'Ophthalmologists', 'Oncologists (cancer)', 'Orthopaedic Surgery',
               'Otorhinolaryngologists', 'Paediatrists', 'Pathologists', 'Plastic Surgeons', 'Pneumology', 'Psychiatrists', 'Rheumatologists', 'Radiology',
               'Surgeons', 'Sports Medicine', 'Travel Medicine', 'Urologists', 'Venerology']
  end
end
