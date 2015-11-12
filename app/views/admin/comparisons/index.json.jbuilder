json.array!(@comparison) do |comparison|
  json.extract! comparison, :id, :name, :name_de, :name_fr, :name_it, :description_de, :description_fr, :description_it
  json.url admin_comparison_url(comparison, format: :json)
end
