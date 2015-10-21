json.array!(@hospitals) do |hospital|
  json.extract! hospital, :name, :title, :address, :email, :phone1, :phone2, :location, :canton
  json.distance hospital.distance_to @location
  json.bearing compass_point(hospital.bearing_to @location)
  json.url hospital_url(hospital, format: :json)
end
