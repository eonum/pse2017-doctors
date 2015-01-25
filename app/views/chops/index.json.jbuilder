json.array!(@chops) do |chop|
  json.extract! chop, :code, :text
  json.url chop_url(chop, format: :json)
end
