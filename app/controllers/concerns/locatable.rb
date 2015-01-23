module Locatable
  extend ActiveSupport::Concern

  included do
    attr_accessor :location
    before_action :set_location
  end

  def default_location #lat/lng
    [46.950745, 7.440618]
  end

  def ip_location
    loc = request.location.coordinates
    valid_location? loc ? loc : nil
  end

  def supplied_location
    params[:location] ? params[:location].split(',').map(&:to_f) : nil
  end

  def set_location
    @location = supplied_location || ip_location || default_location
  end

  def valid_location?(location)
    location[0] > 0 and location[1] > 0
  end
end

