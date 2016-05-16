json.array!(@comparisons) do |comparison|
  json.name comparison.localized_field 'name', locale
  json.url comparison_url(comparison, format: :json)
end
