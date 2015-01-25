json.extract! @icd, :code, :text
json.subclasses @icd.subclass_objects do |sc|
  json.extract! sc, :code, :text
  t, m = sc.clean_text
  json.clean_text t if m
  json.related m[1] if m
  json.url icd_url(sc)
end
