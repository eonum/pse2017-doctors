class Admin::DoctorsController < Admin::AdminController
  before_action :set_doctor, only: [:show, :edit, :update, :destroy, :geolocate]

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
    @cantons = ['AG','AR','AI','BL','BS','BE','FR','GE','GL','GR','JU','LU','NE','NW','OW','SH','SZ','SO','SG','TI','TG','UR','VD','VS','ZG','ZH']
    @fields = ['Zusätzlicher Fachbereich','test1','test2','test3','test4']
    @fieldNumber = @doctor.docfields.size()-1

  end
  def create
    @doctor = Doctor.new(doctor_params)

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
      redirect_to :back, notice: 'Erfolgreich neu lokalisiert.'
    else
      redirect_to :back, alert: "Fehler bei der Lokalisation dieses Arztes. #{@doctor.errors.full_messages.each{|msg| msg}}"
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_doctor
    @doctor = Doctor.find(params['id'])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def doctor_params
    p = params.require(:doctor).permit(:name, :title, :address, :email, :website, :phone1, :phone2, :canton, :docfields, :location)
    p[:docfields] = p[:docfields].split(',').map(&:strip) if p[:docfields]
    p
  end
end
