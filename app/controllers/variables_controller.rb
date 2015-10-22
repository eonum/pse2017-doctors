class VariablesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @sets = []
    @sets = params['hidden-sets'.to_sym].split(',') unless params['hidden-sets'.to_sym].blank?
    @sets << params[:sets] unless params[:sets].blank?
    @variables = @sets.empty? ? Variable : Variable.where({ 'variable_sets' => { '$in' => @sets }})
    query = escape_query(params[:q])
    query = /#{Regexp.escape(query)}/i
    lang = locale.to_s
    @variables = @variables.where({'$or' => [{'field_name' => query},
                                             {"name_#{lang}" => query}]})
                     .order_by([[ :rank, :asc ]])
  end

  def show
    @variable = Variable.find(params[:id])
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
        format.html { redirect_to @variable, notice: 'Variable was successfully created.' }
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
        format.html { redirect_to @variable, notice: 'Variable was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
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
      format.html { redirect_to variables_url }
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

  def variable_params
    params.require(:variable).permit(:field_name, :rank, :import_rank, :name_de,:name_fr, :name_it,
                                     :description_de, :description_fr,:description_it, :variable_type,
                                     :variable_sets => [], :values => [], :values_de => [], :values_fr => [],
                                     :values_it => [])
  end
end