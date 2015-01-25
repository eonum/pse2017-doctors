class ChopsController < ApplicationController
  def index
    @chops = Chop.order_by(:code.asc).limit(10)
  end

  def show
    @chop = Chop.find_by(code: params['id'])
  end
end
