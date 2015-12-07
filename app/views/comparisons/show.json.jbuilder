json.name @comparison.localized_field 'name', locale
json.description @comparison.localized_field 'description', locale
json.base_year @comparison.base_year

json.variables @variables do |v|
  json.name v.localized_field 'name', locale
  json.description v.localized_field 'description', locale
  json.vartype v.variable_type
  json.highlight_threshold v.highlight_threshold
  json.is_time_series v.is_time_series
end

field_names = @variables.map {|v| v.field_name.to_sym }

json.hospitals @hospitals do |h|
  json.name h.name
  json.address2 h.address2

  json.url hospital_url(h, format: :json)

  field_names.each do |field|
    json.set! field, h[field]
  end
end
