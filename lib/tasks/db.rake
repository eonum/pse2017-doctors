require_relative 'seed_helpers.rb'

namespace :db do
  desc 'Import Hospital Locations'
  task seed_hospital_locations: :environment do
    HospitalLocation.delete_all

    file = Rails.root.join('data', 'medical', 'hospital_locations.csv')
    count = `wc -l #{file}`.to_i

    pg = ProgressBar.create(total: count, title: 'Indexing HospitalLocation Fields')

    doc_file = IO.readlines(file)

    # Find all docfields for each doctor
    d_hash = {}
    doc_file.each_with_index do |line, index|
      row = line.split(';')

      name = row[1].strip
      title = (row[2]||'').strip
      field = (row[8]||'').strip

      if d_hash.has_key?(name+title)
        d_hash[name+title][:fields] << field
      else
        d_hash[name+title] = {line: index, fields: [field]}
      end

      pg.increment
    end

    pg = ProgressBar.create(total: d_hash.size, title: 'Importing Hospital Locations')
    d_hash.each do |k, v|
      row = doc_file[v[:line]].split(';')
      HospitalLocation.create do |d|
        d.doc_id = row[0].strip.to_i
        d.name = row[1].strip
        d.title = (row[2]||'').strip
        d.address = (row[3]||'').strip
        d.email = (row[4]||'').strip
        d.phone1 = (row[5]||'').strip
        d.phone2 = (row[6]||'').strip
        d.canton = (row[7]||'').strip
        d.location = [row[9].strip.to_f, row[10].strip.to_f] # long/lat
      end

      pg.increment
    end

    HospitalLocation.create_indexes
  end

  desc 'Import KZP variables'
  task seed_hospital_variables: :environment do
    Variable.where({ 'variable_sets' => { '$in' => ['kzp'] }}).delete

    file = Rails.root.join('data', 'medical', 'kzp12_daten_hospital_variables.csv')
    count = `wc -l #{file}`.to_i

    var_file = IO.readlines(file)

    pg = ProgressBar.create(total: count, title: 'Importing hospital variables')
    var_file.each_with_index do |line, index|
      row = line.split(';')
      next if row[0].strip.blank? || index == 0
      Variable.create do |d|
        d.rank = index
        d.import_rank = index - 1
        d.field_name = row[0].strip
        d.name_de = row[1].strip
        d.name_fr = row[2].strip
        d.name_it = row[3].strip
        d.variable_sets = ['kzp']
        # TODO determine variable type: number, array, ..
      end

      pg.increment
    end

    Variable.create_indexes
  end

  desc 'Import Hospitals'
  task seed_hospitals: :environment do
    Hospital.delete_all

    file = Rails.root.join('data', 'medical', 'kzp12_daten.csv')
    count = `wc -l #{file}`.to_i
    hop_file = IO.readlines(file)
    variables = {}
    # Use only the variables described in the KZP variable set.
    valid_field_names = Variable.where({ 'variable_sets' => { '$in' => ['kzp'] }}).map {|var| var.field_name }

    pg = ProgressBar.create(total: count, title: 'Importing Hospitals')
    hop_file.each_with_index do |line, index|
      next if line.blank?
      row = line.split(';')
      if(index == 0)
        row.each_with_index { |var_name, index| variables[index] = var_name if(valid_field_names.include? var_name) }
        next
      end

      next if row[1].strip.blank?
      Hospital.create do |d|
        # TODO parse values (numbers, arrays, ..)
        variables.each {|index, field_name| d[field_name] = (row[index]||'').strip}
      end

      pg.increment
    end

    # dummy hospital CH
    Hospital.create do |d|
      d.name = 'CH'
      d.canton = 'CH'
    end

    HospitalLocation.create_indexes
  end

  desc 'Import QIP variables'
  task seed_qip_variables: :environment do
    Variable.where({ 'variable_sets' => { '$in' => ['qip'] }}).delete

    folder = Rails.root.join('data', 'medical', 'qip13_refdata')
    files = Dir.entries(folder)
    files.sort!
    count = files.length
    pg = ProgressBar.create(total: count, title: 'Importing QIP variables')

    files.each_with_index do |file_name, index|
      file_name = folder.join(file_name)
      next if File.directory? file_name
      # get the second line with the description.
      file = File.new(file_name, 'r', :encoding => 'iso-8859-15')
      file.gets
      line = file.gets
      next if line.blank? || line.strip.blank?

      Variable.create do |d|
        row = line.split('//')
        d.rank = index
        d.import_rank = index
        sub_row = row[0].split(' ')
        d.field_name = sub_row[0].strip.gsub('.', '_')
        type = d.field_name[d.field_name.length - 1]
        d.variable_type = 'percentage' if('M' == type || 'P' == type)
        d.variable_type = 'number' if('F' == type)
        d.name_de = row[0].gsub(d.field_name, '').strip
        d.name_fr = row[1].strip
        d.name_it = row[2].strip
        d.variable_sets = ['qip', type]
      end
      file.close

      pg.increment
    end

    Variable.create_indexes
  end

  desc 'Import QIP data'
  task seed_qip_data: :environment do
    variables = {}
    Variable.where({ 'variable_sets' => { '$in' => ['qip'] }}).each {|var| variables[var.field_name] = var}
    hospitals = {}
    Hospital.all.each {|hop| hospitals[hop.name] = hop}

    files = {
        2012 => Rails.root.join('data', 'medical', 'qip12_tabdaten.csv'),
        2013 => Rails.root.join('data', 'medical', 'qip13_tabdaten.csv')
    }

    files.each do |year, file|
      count = `wc -l #{file}`.to_i
      qip_file = IO.readlines(file)

      var_not_found = 0
      hop_not_found = 0

      pg = ProgressBar.create(total: count, title: "Importing QIP data from year #{year}")
      qip_file.each_with_index do |line, index|
        next if line.blank?
        row = line.split(';')
        next if row.length < 2
        var_name = row[1].split(' ')[0].gsub('.', '_')

        # non terminal
        next if var_name.length < 7

        var = variables[var_name]
        if var == nil
          var_not_found = var_not_found + 1
          puts "Variable #{var_name} could not be found!"
          next
        end

        hop = hospitals[row[0].strip]
        if hop == nil
          next if row[0].strip.include? 'Spezialklinik'
          hop_not_found = hop_not_found + 1
          puts "Hospital #{row[0].strip} could not be found!"
          next
        end

        qip = {}
        qip['observed'] = (row[6]||'').strip.to_f unless (row[6]||'').blank?
        qip['expected'] = (row[7]||'').strip.to_f unless (row[7]||'').blank?
        qip['SMR'] = (row[8]||'').strip.to_f  unless (row[8]||'').blank?
        qip['num_cases'] = (row[9]||'').strip.to_i  unless (row[9]||'').blank?

        hop[var.field_name] = {} if hop[var.field_name] == nil
        hop[var.field_name][year] = qip
        hop.save!

        pg.increment
      end

      puts "#{var_not_found} variables not found."
      puts "#{hop_not_found} hospitals not found."
    end
  end

  desc 'Link hospitals and their locations'
  task link_hospitals: :environment do
    count =  HospitalLocation.count()
    hop_names = Hospital.all.map {|h| h.name.downcase}
    not_found = 0

  #  pg = ProgressBar.create(total: count, title: 'Linking hospitals and their locations')
    HospitalLocation.all.each do |location|
      hop = Hospital.where(name: /#{location.name}/i).first
      if(hop == nil)
        # search with string edit distance
        hop_name = nearest_name(location.name.downcase, hop_names)
        hop = Hospital.where(name: /#{hop_name}/i).first
        if(hop_name == nil || hop == nil)
          not_found = not_found + 1
          puts "No mapping found for #{location.name}"
          next
        end
        puts "#{location.name} => #{hop.name}"
      end
      location.hospital = hop
      location.save!
#      pg.increment
    end

    puts "No mapping found for #{not_found} locations."
  end

  desc 'Create admin user'
  task seed_admin_user: :environment do
    User.delete_all
    user = User.create!(:email => 'admin@qualitaetsmedizin.ch', :password => 'change_me', :password_confirmation => 'change_me')
    puts 'Admin login created: ' << user.email
  end

  namespace :seed do
    task all: :environment do
      Rake::Task['db:mongoid:remove_indexes'].execute
      Rake::Task['db:seed_hospital_locations'].execute
      Rake::Task['db:seed_hospital_variables'].execute
      Rake::Task['db:seed_hospitals'].execute
      Rake::Task['db:seed_qip_variables'].execute
      Rake::Task['db:seed_qip_data'].execute
    #  Rake::Task['db:link_hospitals'].execute
      Rake::Task['db:seed_admin_user'].execute
      Rake::Task['db:mongoid:create_indexes'].execute
    end
  end
end
