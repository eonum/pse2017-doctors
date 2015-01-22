json.hospital do
  json.extract! @hospital, :doc_id, :name, :title, :address, :phone1, :phone2, :location
end

