module ComparisonsHelper
  def format_hospital_variable variable, hospital, comparison
    value = hospital[variable.field_name]
    return '' if value.nil?
    value = value[comparison.base_year] if variable.is_time_series
    return '' if value.nil?
    return "#{'%.1f' % value}%" if variable.variable_type == :percentage
    value
  end

  def hospital_variable_class variable, hospital, comparison
    classes = []
    value = hospital[variable.field_name]
    return '' if value.nil?
    value = value[comparison.base_year] if variable.is_time_series
    limit = variable.highlight_threshold
    classes << 'orange-highlight' if(limit > 0 && limit < 100 && limit <= value)

    return classes.join(' ')
  end
end
