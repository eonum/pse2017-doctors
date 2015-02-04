require_relative '../models/service/speciality_finder.rb'

class SpecialitiesController < ApplicationController
  include Locatable

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
    @doctors = Doctor.near(@location, 50).where(speciality_ids: @speciality.id).limit(5)
  end
end
