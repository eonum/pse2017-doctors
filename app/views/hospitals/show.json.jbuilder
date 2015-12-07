json.extract! @hospital, :name, :address1, :address2, :bfs_typo, :canton, :location

json.locations @hospital.hospital_locations do |l|
  json.name l.name
  json.title l.title
  json.address l.address
  json.email l.email
  json.phone1 l.phone1
  json.phone2 l.phone2
  json.canton l.canton
  json.location l.location
end

