json.array!(@icds) do |icd|
  json.extract! icd, :code, :text
  json.url icd_url(icd, format: :json)
end
