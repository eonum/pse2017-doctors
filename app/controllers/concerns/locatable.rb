module Locatable
  extend ActiveSupport::Concern

  included do
    attr_accessor :location
    before_action :set_location

    helper_method :cantons
  end

  def set_location
    @location = supplied_location || ip_location || default_location
  end

  def default_location #lat/lng
    [46.950745, 7.440618] # Berne center
  end

  def ip_location
    if request.location
      loc = request.location.coordinates
      valid_location? loc ? loc : nil
    else
      nil
    end
  end

  def supplied_location
    if params[:location] && params[:location].match(/^(\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)$/)
      params[:location].split(',').map(&:to_f)
    elsif params[:canton]
      canton = params[:canton].upcase.to_sym
      cantons[canton][:location] if cantons.has_key? canton
    else
      nil
    end
  end

  def valid_location?(location)
    location[0] > 0 and location[1] > 0
  end

end

