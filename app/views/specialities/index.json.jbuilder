json.array!(@specialities) do |speciality|
  json.extract! speciality, :code, :name
  json.url speciality_url(speciality, format: :json)
end
