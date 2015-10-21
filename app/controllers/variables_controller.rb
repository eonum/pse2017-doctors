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
    @variable = Variable.new(params[:variable])
    preprocess_values params

    respond_to do |format|
      if @variable.save
        DescriptionCache.reload_variable_cache
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
      if @variable.update_attributes(params[:variable])
        DescriptionCache.reload_variable_cache
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
end
