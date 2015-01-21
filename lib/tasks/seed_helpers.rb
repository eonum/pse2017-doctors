def parse_psql_array(arr_str)
  return [] if arr_str.nil? or arr_str == ''
  arr_str[1..-2].split ','
end