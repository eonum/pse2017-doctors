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

def hospital_cache
  cache = {}
  Hospital.all.each do |h|
    cache[clean_string h.name] = h unless h.name.blank?
    cache[clean_string h.address1] = h unless h.address1.blank?
    cache[clean_string h.address2] = h unless h.address2.blank?
    h['Inst'].each { |year, inst| cache[clean_string inst] = h unless inst.blank? } unless (h['Inst'] == nil)
    h['Adr'].each { |year, adr| cache[clean_string adr] = h unless adr.blank? } unless (h['Adr'] == nil)
  end
  cache
end

def clean_string string
  string.strip.downcase
end

# find the corresponding hospital by exact matching of one of the provided fields.
def get_hospital hospital_cache, name, address1 = '', address2 = '', name2 = ''
  h = nil
  h = hospital_cache[clean_string name] if !name.blank?
  h = hospital_cache[clean_string address1] if h.nil? && !address1.blank?
  h = hospital_cache[clean_string address2] if h.nil? && !address2.blank?
  h = hospital_cache[clean_string name2] if h.nil? && !name2.blank?
  h
end

def is_numeric? string
  string = escape_numeric(string)
  string.to_i.to_s == string || string.to_f.to_s == string
end

def escape_numeric(string)
  string.strip.gsub('%', '').gsub("'", '').gsub(',', '')
end

def safe_import_integer string, default_value = nil
  return default_value if string.blank?
  string = escape_numeric string
  string = string.split('.')[0] if string.include? '.'
  (!string.blank? && string.match(/^-?\d+$/)) ? Integer(string) : -1
end

def safe_import_float string
  return nil if string.blank?
  # TODO remove this line when we do no longer use
  string = string.gsub(',', '.')
  string = escape_numeric string
  (!string.blank? && string.match(/^-?[\d|\.]+$/)) ? Float(string) : -1.0
end

def safe_import_boolean string
  string == '1'  || string == 'X' || string == 'x'
end

def safe_import_date string
  return nil if string.blank?
  date = nil
  begin
    date = Date.parse(string)
  rescue
    date = nil
  end
  date
end

