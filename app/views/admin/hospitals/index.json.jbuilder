json.array!(@hospitals) do |admin_hospital|
  json.extract! admin_hospital, :id, :name, :address1, :address2, :bfs_typo, :canton
  json.url admin_hospital_url(admin_hospital, format: :json)
end
