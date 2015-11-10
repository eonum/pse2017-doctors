json.array!(hospital_locations) do |admin_hospital_location|
  json.extract! admin_hospital_location, :id, :doc_id, :name, :title, :address, :email, :phone1, :phone2, :canton, :location
  json.url admin_hospital_location_url(admin_hospital_location, format: :json)
end
