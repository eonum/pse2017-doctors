json.extract! @comparison, :code, :name
json.fallbacks @fallbacks do |fb|
  json.extract! fb, :name
  json.url comparison_url(fb)
end
