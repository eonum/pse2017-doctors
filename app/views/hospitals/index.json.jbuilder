json.array!(@hospitals) do |hospital|
  json.extract! hospital, :doc_id, :name, :title, :address, :location
  json.distance hospital.distance_to @location
  json.bearing compass_point(hospital.bearing_to @location)
  json.url hospital_url(hospital, format: :json)
end
