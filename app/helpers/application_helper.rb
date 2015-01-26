module ApplicationHelper
  def compass_point(location)
    Geocoder::Calculations.compass_point location
  end

  def current_language
    case I18n.locale
      when :de then 'Deutsch'
      when :fr then 'Francais'
      when :it then 'Italiana'
      when :en then 'English'
      else 'No Idea'
    end
  end
end
