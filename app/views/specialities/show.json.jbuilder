json.extract! @speciality, :code, :name
json.fallbacks @fallbacks do |fb|
  json.extract! fb, :name
  json.url speciality_url(fb)
end
