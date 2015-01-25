json.array!(@specialities) do |speciality|
  json.extract! speciality, :code, :name
  json.relatedness  rand.round 2
  json.url speciality_url(speciality, format: :json)
end
