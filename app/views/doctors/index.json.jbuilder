json.array!(@doctors) do |doctor|
  json.extract! doctor, :doc_id, :name, :title, :address, :location
  json.distance doctor.distance_to @location
  json.bearing compass_point(doctor.bearing_to @location)
  json.url doctor_url(doctor, format: :json)
end
