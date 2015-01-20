json.array!(@hospitals) do |hospital|
  json.extract! hospital, :id
  json.url api_hospital_url(hospital, format: :json)
end
