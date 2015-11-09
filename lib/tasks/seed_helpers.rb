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

def nearest_name name, names
  name = clean(name)
  min = name.length.to_f * 0.3
  min_name = nil

  names.each do |n|
    n_clean = clean(n)
    d = levenshtein_distance(name, n_clean)
    if(d < min)
      min = d
      min_name = n
    end
  end
  min_name
end

def clean name
  name = name.gsub('klinik', '')
  name = name.gsub('spital', '')
  name = name.gsub('gruppe', '')
  name = name.gsub('dienst', '')
  name = name.gsub('kanton', '')
  name = name.gsub('geburtshaus', '')
  name = name.gsub('clinique', '')
  name = name.gsub('hôpital', '')
  name = name.gsub('clinica', '')
  name = name.gsub('ag', '')
  name = name.gsub('sa', '')
  name = name.gsub('  ', ' ')
  name.strip
end

def levenshtein_distance(s, t)
  m = s.length
  n = t.length
  return m if n == 0
  return n if m == 0
  d = Array.new(m+1) {Array.new(n+1)}

  (0..m).each {|i| d[i][0] = i}
  (0..n).each {|j| d[0][j] = j}
  (1..n).each do |j|
    (1..m).each do |i|
      d[i][j] = if s[i-1] == t[j-1]  # adjust index into string
                  d[i-1][j-1]       # no operation required
                else
                  [ d[i-1][j]+1,    # deletion
                    d[i][j-1]+1,    # insertion
                    d[i-1][j-1]+1,  # substitution
                  ].min
                end
    end
  end
  d[m][n]
end
