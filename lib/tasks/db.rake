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

    pg = ProgressBar.create(total: count, title: 'Importing hospital variables 2013')
    var_file.each_with_index do |line, index|
      pg.increment
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
        d.is_time_series = true
        # TODO determine variable type: number, array, ..
      end
    end

    Variable.create_indexes
  end

  desc 'Import Hospitals'
  task seed_hospitals: :environment do
    Hospital.delete_all

    # configuration
    master = 2013
    files = {
        2013 => Rails.root.join('data', 'medical', 'kzp13_daten.csv'),
        2012 => Rails.root.join('data', 'medical', 'kzp12_daten.csv'),
        2011 => Rails.root.join('data', 'medical', 'kzp11_daten.csv')
    }

    # Use only the variables described in the KZP variable set.
    variables = {}
    valid_field_names = Variable.where({ 'variable_sets' => { '$in' => ['kzp'] }}).map {|var| var.field_name }

    # read master hospitals and their addresses
    count = `wc -l #{files[master]}`.to_i
    hop_file = IO.readlines(files[master])

    pg = ProgressBar.create(total: count, title: 'Importing Hospitals Master')
    hop_file.each_with_index do |line, index|
      pg.increment

      next if line.blank?
      row = line.split(';')
      next if(index == 0)

      next if row[1].strip.blank?
      Hospital.create do |d|
        d.canton = row[0].strip
        d.name = row[1].strip
        d.address1 = row[2].strip
        d.address2 = row[3].strip
        d.bfs_typo = row[4].strip
      end
    end

    hop_cache = hospital_cache()
    hop_not_found = {}

    files.each do |year, file|
      count = `wc -l #{file}`.to_i
      hop_file = IO.readlines(file)

      pg = ProgressBar.create(total: count, title: "Importing Hospitals #{year}")
      hop_file.each_with_index do |line, index|
        pg.increment

        next if line.blank?
        row = line.split(';')
        if(index == 0)
          row.each_with_index { |var_name, index| variables[index] = var_name if(valid_field_names.include? var_name) }
          next
        end

        next if row[1].strip.blank?

        hop = get_hospital(hop_cache, row[1], row[2])

        if(hop == nil)
          hop_not_found[row[1]] = 1
          next
        end

        # TODO parse values (numbers, arrays, ..)
        variables.each do |index, field_name|
          indicator = hop[field_name] == nil ? {} : hop[field_name].clone
          indicator[year] = (row[index]||'').strip
          hop[field_name] = indicator
          hop.save!
        end

      end

      puts
      puts "#{hop_not_found.length} hospitals not found in master:"
      puts hop_not_found.keys
      puts
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

    already_processed = {}

    files.each_with_index do |file_name, index|
      pg.increment
      file_name = folder.join(file_name)
      next if File.directory? file_name
      # get the second line with the description.
      file = File.new(file_name, 'r', :encoding => 'iso-8859-15')
      file.gets
      line = file.gets
      next if line.blank? || line.strip.blank?

      row = line.split('//')
      sub_row = row[0].split(' ')
      field_name = sub_row[0].strip.gsub('.', '_')
      next if already_processed[field_name] == 1
      already_processed[field_name] = 1
      type = field_name[field_name.length - 1]

      ['observed', 'expected', 'SMR', 'num_cases'].each do |sub_var|
        Variable.create do |d|
          d.rank = index
          d.import_rank = index
          d.field_name = field_name + '_' + sub_var
          d.variable_type = 'percentage' if('M' == type || 'P' == type)
          d.variable_type = 'number' if('F' == type || 'X' == type || sub_var == 'num_cases')
          d.name_de = row[0].gsub(d.field_name, '').strip
          d.name_fr = row[1].strip
          d.name_it = row[2].strip
          d.variable_sets = ['qip', type]
          d.is_time_series = true
        end
      end
      file.close
    end

    Variable.create_indexes
  end

  desc 'Import QIP data'
  task seed_qip_data: :environment do
    variables = {}
    Variable.where({ 'variable_sets' => { '$in' => ['qip'] }}).each {|var| variables[var.field_name] = var}

    hop_cache = hospital_cache()

    files = {
        2012 => Rails.root.join('data', 'medical', 'qip12_tabdaten.csv'),
        2013 => Rails.root.join('data', 'medical', 'qip13_tabdaten.csv')
    }

    files.each do |year, file|
      count = `wc -l #{file}`.to_i
      qip_file = IO.readlines(file)

      var_not_found = {}
      hop_not_found = {}

      pg = ProgressBar.create(total: count, title: "Importing QIP data from year #{year}")
      qip_file.each_with_index do |line, index|
        pg.increment

        next if line.blank?
        row = line.split(';')
        next if row.length < 2
        var_name = row[1].split(' ')[0].gsub('.', '_')

        # non terminal
        next if var_name.length < 7
        # Indikator, indicator or indicatore
        next if var_name.include? 'ndi'

        var = variables[var_name + '_observed']
        if var == nil
          var_not_found[var_name] = 1
          next
        end

        field_name_base = var.field_name.gsub('_observed', '')

        hop_name = row[0].strip
        hop = get_hospital(hop_cache, hop_name)
        if hop == nil
          hop_not_found[hop_name] = 1
          next
        end

        if is_numeric?(row[6]||'')
          qip = hop[field_name_base + '_observed'] == nil ? {} : hop[field_name_base + '_observed'].clone
          qip[year] = (row[6]||'').to_f
          hop[field_name_base + '_observed'] = qip
        end

        if is_numeric?(row[7]||'')
          qip = hop[field_name_base + '_expected'] == nil ? {} : hop[field_name_base + '_expected'].clone
          qip[year] = (row[7]||'').to_f
          hop[field_name_base + '_expected'] = qip
        end

        if is_numeric?(row[8]||'')
          qip = hop[field_name_base + '_SMR'] == nil ? {} : hop[field_name_base + '_SMR'].clone
          qip[year] = (row[8]||'').to_f
          hop[field_name_base + '_SMR'] = qip
        end

        if is_numeric?(row[9]||'')
          qip = hop[field_name_base + '_num_cases'] == nil ? {} : hop[field_name_base + '_num_cases'].clone
          qip[year] = (row[9]||'').to_f
          hop[field_name_base + '_num_cases'] = qip
        end

        hop.save!
      end

      puts
      puts "#{var_not_found.length} variables not found:"
      puts var_not_found.keys
      puts
      puts "#{hop_not_found.length} hospitals not found:"
      puts hop_not_found.keys
      puts
    end
  end

  desc 'Link hospitals and their locations'
  task link_hospitals: :environment do
    count =  HospitalLocation.count()
    hop_cache = hospital_cache()
    hop_not_found = {}

    #pg = ProgressBar.create(total: count, title: 'Linking hospitals and their locations')
    HospitalLocation.all.each do |location|
      #pg.increment
      hop = get_hospital(hop_cache, location.name, location.address.split(',')[0])

      if(hop == nil)
        hop_not_found[location.name] = 1
        next
      end

      location.hospital = hop
      location.save!
    end

    puts
    puts "No mapping found for #{hop_not_found.length} locations:"
    puts hop_not_found.keys
    puts
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
      Rake::Task['db:link_hospitals'].execute
      Rake::Task['db:seed_admin_user'].execute
      Rake::Task['db:mongoid:create_indexes'].execute
    end
  end

  desc "Load a CSV file with additional information by hosptial"
  task :load_csv, [:file_name] => :environment do  |t, args|
    hop_cache = hospital_cache()
    hop_not_found = {}

    count = `wc -l #{args.file_name}`.to_i

    file = File.new(args.file_name, 'r')
    header = file.gets.split(';')
    header.shift

    pg = ProgressBar.create(total: count, title: "Load #{args.file_name}")
    while line = file.gets
      pg.increment

      vars = line.split(';')
      hop = get_hospital hop_cache, vars[0]
      if(hop == nil)
        hop_not_found[vars[0]] = 1
        next
      end
      
      header.each_with_index do |field_name, index|
        hop[field_name.strip] = vars[index + 1].strip
      end
      hop.save
    end

    pg.finish
    file.close

    puts
    puts "#{hop_not_found.length} hospitals not found in master:"
    puts hop_not_found.keys
    puts

  end
end
