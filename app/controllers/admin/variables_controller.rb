class Admin::VariablesController < Admin::AdminController
  before_filter :authenticate_user!

  def index
    @sets = []
    @sets = params['hidden-sets'.to_sym].split(',') unless params['hidden-sets'.to_sym].blank?
    @sets << params[:sets] unless params[:sets].blank?
    @variables = @sets.empty? ? Variable : Variable.where({ 'variable_sets' => { '$in' => @sets }}).order_by([[ :rank, :asc ]])
    query = escape_query(params[:q])
    query = /#{Regexp.escape(query)}/i
    lang = locale.to_s
    @variables = @variables.where({'$or' => [{'field_name' => query},
                                             {"name_#{lang}" => query}]})
                     .order_by([[ :rank, :asc ]])
    @variables = @variables.paginate(:page => params[:page], :per_page => 10)
  end

  def new
    @variable = Variable.new
  end

  def edit
    @variable = Variable.find(params[:id])
  end

  def create
    @variable = Variable.new(variable_params)
    preprocess_values params

    respond_to do |format|
      if @variable.save
        format.html { redirect_to admin_variables_path, notice: t('variable_created') }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @variable = Variable.find(params[:id])
    preprocess_values params

    respond_to do |format|
      if @variable.update_attributes(variable_params)
        format.html { redirect_to admin_variables_path, notice: t('variable_updated') }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # JSON API for search
  # parameters:
  # term: search term
  # limit: maximum number of items
  # locale: language for search term and results
  def search model
    res = []
    query = params[:term].blank? ? '' : params[:term]
    limit = params[:limit].blank? ? 5 : params[:limit].to_i
    variables = Variable.where({'text_' + locale => /#{Regexp.escape(query)}/i}).limit(limit)
    variables.each do |var|
      res << {:id => var.id.to_s, :text => var.name(locale)}
    end

    render :json => res
  end

  def preprocess_values params
    params[:variable][:values] = [] if params[:variable][:values] == nil
    params[:variable][:values_de] = [] if params[:variable][:values_de] == nil
    params[:variable][:values_fr] = [] if params[:variable][:values_fr] == nil
    params[:variable][:values_it] = [] if params[:variable][:values_it] == nil
  end

  def destroy
    @variable = Variable.find(params[:id])
    @variable.destroy

    respond_to do |format|
      format.html { redirect_to [:admin, @variable] }
    end
  end

  def set_variable_sets
    @variable = Variable.find(params[:id])
    sets = params['hidden-sets'.to_sym].split(',')
    sets << params[:sets] unless params[:sets].blank?
    @variable.variable_sets = sets
    @variable.save!
    redirect_to variables_path()
  end

  def calculate
    @variable = Variable.find(params[:id])
    msg = @variable.calculate_value_for Hospital.all

    redirect_to edit_admin_variable_path(@variable), notice: msg
  end

  def variable_params
    params.require(:variable).permit(:field_name, :rank, :import_rank, :name_de,:name_fr, :name_it,
                                     :description_de, :description_fr,:description_it, :variable_type,
                                     :highlight_threshold, :is_time_series,
                                     :variable_sets => [], :values => [], :values_de => [], :values_fr => [],
                                     :values_it => [])
  end
end
