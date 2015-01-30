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

  def current_address
    cookies[:location] || 'No location set'
  end

  def fa_icon(name)
    content_tag(:i, class: "fa fa-#{name}")
  end

  def progress_bar(value, css_class)
    content_tag(:div, class: "progress #{css_class}") do
      content_tag(:div, class: 'progress-bar', role: 'progressbar', 'aria-valuenow' => value,
      'aria-valuemin' => 0, 'aria-valuemax' => 100, style: "width: #{value}%;" ) do
        content_tag(:span, 'BLabla',  class: 'sr-only')
      end
      # raw '<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 60%;">
      #   <span class="sr-only">60% Complete</span>
      # </div>'
    end
  end
end
