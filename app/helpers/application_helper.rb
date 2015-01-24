module ApplicationHelper
  def compass_point(location)
    Geocoder::Calculations.compass_point location
  end
end
