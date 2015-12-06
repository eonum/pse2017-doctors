json.hospital do
  json.extract! @hospital, :name, :title, :address, :phone1, :phone2, :location
end

