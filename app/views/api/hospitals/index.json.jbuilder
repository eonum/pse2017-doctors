json.array!(@hospitals) do |hospital|
  json.extract! hospital, :doc_id, :name, :title, :address
  json.url api_hospital_url(hospital, format: :json)
end
