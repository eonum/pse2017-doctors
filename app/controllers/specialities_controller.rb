require_relative '../models/service/speciality_finder.rb'

class SpecialitiesController < ApplicationController
  def index
    if params[:code]
      @specialities = SpecialityFinder.new.find(params[:code])
    else
      @specialities = Speciality.all
    end
  end

  def show
    @speciality = Speciality.find_by(code: params['id'])
    @fallbacks = @speciality.fallbacks.map { |fb| Speciality.find_by(code: fb) }
  end
end


