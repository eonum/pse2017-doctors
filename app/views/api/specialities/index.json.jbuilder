json.array!(@specialities) do |speciality|
  json.extract! speciality, :code, :name, :fallbacks
  json.url api_speciality_url(speciality, format: :json)
end
