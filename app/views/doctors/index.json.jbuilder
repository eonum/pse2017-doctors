json.array!(@doctors) do |doctor|
  json.extract! doctor, :doc_id, :name, :title, :address
  json.url doctor_url(doctor, format: :json)
end
