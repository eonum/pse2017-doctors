module ComparisonsHelper
  def format_hospital_variable variable, hospital, comparison
    value = hospital[variable.field_name]
    return '' if value.nil?
    value = value[comparison.base_year] if variable.is_time_series
    return '' if value.nil?

    value
  end
end
