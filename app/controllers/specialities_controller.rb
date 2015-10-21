class SpecialitiesController < ApplicationController
  include Locatable

  def index
   @specialities = Speciality.all
  end

  def show
    @speciality = Speciality.find_by(code: params['id'])
  end
end
