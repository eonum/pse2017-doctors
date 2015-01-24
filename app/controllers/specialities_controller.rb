class SpecialitiesController < ApplicationController
  def index
    @specialities = Speciality.all
  end

  def show
    @speciality = Speciality.find_by(code: params['id'])
    @fallbacks = @speciality.fallbacks.map { |fb| Speciality.find_by(code: fb) }
  end
end


