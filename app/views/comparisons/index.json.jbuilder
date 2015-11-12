json.array!(@comparisons) do |comparison|
  json.extract! comparison, :code, :name
  json.relatedness  rand.round 2
  json.url comparison_url(comparison, format: :json)
end
