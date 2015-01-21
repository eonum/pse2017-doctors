module Api
  class SpecialitiesController < ApplicationController
    def index
      @specialities = Speciality.all
    end

    def show
      @speciality = Speciality.find_by(code: params['code'])
    end
  end
end

