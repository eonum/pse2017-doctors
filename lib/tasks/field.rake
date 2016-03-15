namespace :field do
  desc 'Create a new field by combining existing fields'
  task create: :environment do
    field_name = 'births_relevance'
    description_de = 'Relevanz Geburten'
    year = '2013'

    var = Variable.where(field_name: field_name).first
    if var.nil?
      Variable.create do |v|
        v.field_name = field_name
        v.rank = 200
        v.name_de = description_de
        v.is_time_series = false
        v.variable_type = 'relevance'
      end
      var = Variable.find_by(field_name: field_name)
    end

    data1 = {}
    Hospital.all.each do |h|
      num_births = h['G_1_1_F_num_cases'].nil? ? 0.0 : h['G_1_1_F_num_cases'][year].to_f
      # this is appr. the Swiss average. Every 15th case is a new born.
      num_total = h['AustStatT'].nil? ? 15.0 * num_births : h['AustStatT']['2013'].to_f
      if h['AustStatT'].nil? || h['AustStatT']['2013'].to_f < 150 # Geburtshaus
         data1[h.id] =  Float::NAN
      else
        # avoid division by zero
        num_total = 1.0 if num_total == 0.0
        data1[h.id] =  num_births / num_total
      end
    end
    data1 = normmax data1

  #  data2 = {}
   # Hospital.all.each {|h| data2[h.id] = (h['ortho_hip_tep_numcases'].nil? ? 0.0 : h['ortho_hip_tep_numcases']['2013'].to_f) / (h['AustStatT'].nil? ? 1.0 : h['AustStatT']['2013'].to_f)}
    #data2 = normmax data2

   # data1.each do |key, value|
    #  data1[key] = value + data2[key]
    #end

    data1 = normmax data1
    data1.each do |key, value|
      hop = Hospital.find(key)
      hop[field_name] = value.nan? ? nil : value * 100.0
      hop.save!
    end

  end

  def normmax data
    max = -1.0/0.0 # negative infinity
    data.each { |key, value| data[key] = 0.0 if value.nil?}
    data.each { |key, value| next if value.nan?; max = [max.to_f, value.to_f].max.to_f }
    data.each {|key, value| data[key] = value.to_f / max }
    data
  end

end
