class Admin::ComparisonsController < Admin::AdminController
  before_action :set_comparison, only: [:show, :edit, :update, :destroy]

  # GET /admin/comparisons
  # GET /admin/comparisons.json
  def index
    @comparisons = Comparison.all
  end

  # GET /admin/comparisons/1
  # GET /admin/comparisons/1.json
  def show
  end

  # GET /admin/comparisons/new
  def new
    @comparison = Comparison.new
  end

  # GET /admin/comparisons/1/edit
  def edit
  end

  # POST /admin/comparisons
  # POST /admin/comparisons.json
  def create
    @comparison = Comparison.new(comparison_params)
    set_variables
    respond_to do |format|
      if @comparison.save
        format.html { redirect_to [:admin, @comparison], notice: 'Comparison was successfully created.' }
        format.json { render :show, status: :created, location: [:admin, @comparison] }
      else
        format.html { render :new }
        format.json { render json: @comparison.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/comparisons/1
  # PATCH/PUT /admin/comparisons/1.json
  def update
    set_variables
    respond_to do |format|
      if @comparison.update(comparison_params)
        format.html { redirect_to [:admin, @comparison], notice: 'Comparison was successfully updated.' }
        format.json { render :show, status: :ok, location: [:admin, @comparison] }
      else
        format.html { render :edit }
        format.json { render json: @comparison.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/comparisons/1
  # DELETE /admin/comparisons/1.json
  def destroy
    @comparison.destroy
    respond_to do |format|
      format.html { redirect_to admin_comparisons_url, notice: 'Comparison was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comparison
      @comparison = Comparison.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comparison_params
      params.require(:comparison).permit(:name, :name_de, :name_fr, :name_it, :description_de, :description_fr, :description_it)
    end

    def set_variables
      @comparison.variables = []
      params['comparison']['variable_ids'].each do |var_id|
        @comparison.variables << Variable.find(var_id)
      end
    end
end
