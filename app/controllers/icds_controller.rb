class IcdsController < ApplicationController
  def index
    @icds = Icd.order_by(:code.asc).limit(10)
  end

  def show
    @icd = Icd.find_by(code: params['id'])
    @specialities = SpecialityFinder.new.find(@icd.code)
  end
end
