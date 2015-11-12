json.array!(@admin_fields) do |admin_field|
  json.extract! admin_field, :id
  json.url admin_field_url(admin_field, format: :json)
end
