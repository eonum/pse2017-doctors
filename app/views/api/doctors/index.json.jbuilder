json.array!(@doctors) do |doctor|
  json.extract! doctor, :doc_id, :name, :title, :address
  json.url api_doctor_url(doctor, format: :json)
end
