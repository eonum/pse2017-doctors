json.extract! @speciality, :code, :name
json.fallbacks @fallbacks do |fb|
  json.extract! fb, :code, :name
end
