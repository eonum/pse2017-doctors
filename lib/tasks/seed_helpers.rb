def parse_psql_array(arr_str)
  return [] if arr_str.nil? or arr_str == ''
  arr_str[1..-2].split ','
end

def docfield_to_fmh
  d_to_fmh = {}

  CSV.foreach Rails.root.join('data', 'relations', 'docfield_to_fmh.csv'), col_sep: ',' do |row|
    d_to_fmh[row[0]] = row[3..-1] if row[0]
    d_to_fmh[row[1]] = row[3..-1] if row[1]
    d_to_fmh[row[2]] = row[3..-1] if row[2]
  end

  # Remove nil entries and convert to integers
  d_to_fmh.compact!
  d_to_fmh.each_value {|v| v.compact!}
  d_to_fmh.each_value {|v| v.map!(&:to_i)}

  d_to_fmh
end