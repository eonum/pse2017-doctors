json.array!(doctors) do |admin_doctor|
  json.extract! admin_admin_doctor, :id, :name, :title, :address, :email, :phone1, :phone2, :canton, :location, :docfields
  json.url admin_admin_doctor_url(admin_admin_doctor, format: :json)
end
