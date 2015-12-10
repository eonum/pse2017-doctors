module ComparisonsHelper
  def format_hospital_variable variable, hospital, comparison
    value = hospital[variable.field_name]
    return '' if value.nil?
    value = value[comparison.base_year] if variable.is_time_series
    return '' if value.nil?
    return "#{'%.1f' % value}%" if variable.variable_type == :percentage
    return !value.blank? && value.upcase == 'X' ? image_tag('accept.png', :style => 'border-style:none') : '' if variable.variable_type == :boolean
    value
  end

  def hospital_variable_class variable, hospital, comparison
    classes = []
    value = hospital[variable.field_name]
    return '' if value.nil?
    value = value[comparison.base_year] if variable.is_time_series
    limit = variable.highlight_threshold
    classes << 'orange-highlight' if(limit > 0 && limit < 100 && limit <= value)
    classes << 'text-center' if variable.variable_type == :boolean

    return classes.join(' ')
  end
end
