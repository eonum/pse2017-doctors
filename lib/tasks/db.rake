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
    master = 2014
    files = {
        2014 => Rails.root.join('data', 'medical', 'kzp14_daten.csv'),
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

  desc 'Update Hospitals with KZP data. This task is idempotent'
  task update_hospitals: :environment do

    # configuration
    year = 2014
    file = Rails.root.join('data', 'medical', 'kzp14_daten.csv')

    # Use only the variables described in the KZP variable set.
    variables = {}
    valid_field_names = Variable.where({ 'variable_sets' => { '$in' => ['kzp'] }}).map {|var| var.field_name }

    # read master hospitals and their addresses
    count = `wc -l #{file}`.to_i
    hop_file = IO.readlines(file)

    hop_cache = hospital_cache()

    pg = ProgressBar.create(total: count, title: 'Updating Hospitals Master')
    hop_file.each_with_index do |line, index|
      pg.increment

      next if line.blank?
      row = line.split(';')
      next if(index == 0)

      next if row[1].strip.blank?

      hop = get_hospital(hop_cache, row[1].strip)

      if(hop == nil)
        puts "Add hospital #{row[1].strip} to master"
        Hospital.create do |d|
          d.canton = row[0].strip
          d.name = row[1].strip
          d.address1 = row[2].strip
          d.address2 = row[3].strip
          d.bfs_typo = row[4].strip
        end
      end

    end

    hop_cache = hospital_cache()
    hop_not_found = {}

    count = `wc -l #{file}`.to_i
    hop_file = IO.readlines(file)

    pg = ProgressBar.create(total: count, title: "Updating Hospitals with KZP data #{year}")
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
        #2012 => Rails.root.join('data', 'medical', 'qip12_tabdaten.csv'),
        #2013 => Rails.root.join('data', 'medical', 'qip13_tabdaten.csv'),
        2014 => Rails.root.join('data', 'medical', 'qip14_tabdaten.csv')
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
          qip[year] = escape_numeric(row[6]||'').to_f
          hop[field_name_base + '_observed'] = qip
        end

        if is_numeric?(row[7]||'')
          qip = hop[field_name_base + '_expected'] == nil ? {} : hop[field_name_base + '_expected'].clone
          qip[year] = escape_numeric(row[7]||'').to_f
          hop[field_name_base + '_expected'] = qip
        end

        if is_numeric?(row[8]||'')
          qip = hop[field_name_base + '_SMR'] == nil ? {} : hop[field_name_base + '_SMR'].clone
          qip[year] = escape_numeric(row[8]||'').to_f
          hop[field_name_base + '_SMR'] = qip
        end

        if is_numeric?(row[9]||'')
          qip = hop[field_name_base + '_num_cases'] == nil ? {} : hop[field_name_base + '_num_cases'].clone
          qip[year] = escape_numeric(row[9]||'').to_f
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

  desc "Load a CSV file with additional information by hospital. This task is idempotent."
  task :load_csv, [:file_name, :data_year] => :environment do  |t, args|
    hop_cache = hospital_cache()
    hop_not_found = {}

    count = `wc -l #{args.file_name}`.to_i

    file = File.new(args.file_name, 'r')
    header = file.gets.split(';')
    header.shift
    # create variables
    header_types = {}
    header.each_with_index do |head, index|
      h_vars = head.split('--')
      field_name = h_vars[0].strip
      variable_type = 'string'
      variable_type = h_vars[1] unless h_vars[1].nil?
      header_types[field_name] = variable_type.to_sym

      next if field_name.blank?
      next if(Variable.where(field_name: field_name).exists?())

      # skip variable creation by uncommenting this line
      # next
      Variable.create do |d|
        d.rank = index
        d.import_rank = index
        d.field_name = field_name
        d.variable_type = variable_type
        d.name_de = h_vars[2] unless h_vars[2].nil?
        d.name_fr = h_vars[2] unless h_vars[3].nil?
        d.name_it = h_vars[2] unless h_vars[4].nil?
        d.variable_sets = [args.file_name]
        d.is_time_series = true unless args.data_year.blank?
      end
    end
    header.map!{|h| h.split('--')[0].strip}.reject!{|h| h.blank?}

    year = args.data_year.to_i

    pg = ProgressBar.create(total: count, title: "Load #{args.file_name}")
    while line = file.gets
      pg.increment

      vars = (line + ' ').split(';')
      hop = get_hospital hop_cache, vars[0]
      if(hop == nil)
        hop_not_found[vars[0]] = 1
        next
      end
      
      header.each_with_index do |field_name, index|
        value = vars[index + 1].strip
        value = safe_import_integer value if header_types[field_name] == :number
        value = safe_import_float value if header_types[field_name] == :percentage

        next if value.blank?

        if(year != 0)
          field = hop[field_name] == nil ? {} : hop[field_name].clone
          field[year] = value
          hop[field_name] = field
        else
          hop[field_name] = value unless value.nil?
        end
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

  desc 'Geocode Hospitals by full address'
  task :geocode_hospitals => :environment do

    pg = ProgressBar.create(total: Hospital.count, title: 'Geocoding Hospitals:')

    Hospital.all.each do |h|
      location = Geocoder.coordinates(h.full_address)
      location = Geocoder.coordinates(h.address2) if location == nil
      location = Geocoder.coordinates(h.name) if location == nil
      h.location = [location[1], location[0]]
      h.save
      # add timeout so Google is happy
      sleep(1)

      pg.increment
    end
  end

  desc 'Seed Doctors'
  task :seed_doctors => :environment do
    Doctor.delete_all

    file = Rails.root.join 'data', 'doctor', 'doctors.csv'
    count = `wc -l #{file}`.to_i

    pg = ProgressBar.create(total: count, title: 'Seeding Doctors')

    IO.foreach(file) do |line|
      row = line.split ';'
      speciality = row[8].strip

      pg.increment
      next if speciality == 'spital'

      name, title, address, email, phone1, phone2, canton = row.values_at(1,2,3,4,5,6,7)
      location = row.values_at(9, 10).map(&:to_f)

      Doctor.create! name: name, title: title, address: address, email: email,
                     phone1: phone1, phone2: phone2, canton: canton, location: location, docfields: speciality.split(',')
    end

  end

  desc 'load drgsearch data from FOPH. Idempotent. Variables are not created.'
  task :load_drgsearch_data, [:directory, :year, :version] => :environment do |t, args|
    # the variables have to exist or must be created manually
    variables = {
        obstetrics_numcases: ['14'],
        cardiology_numcases: ['05'],
        ortho_numcases:['I03', 'I04', 'I05', 'I07', 'I08', 'I13', 'I14', 'I18', 'I20',
                        'I21', 'I23', 'I25', 'I27', 'I28', 'I29', 'I30', 'I33', 'I36',
                        'I43', 'I44', 'I46', 'I47', 'I59', 'I60', 'I64', 'I74', 'I77',
                        'I78', 'I95'],
        ortho_hip_tep_numcases: ['I03', 'I05', 'I08', 'I21', 'I46', 'I47'],
        ortho_knee_tep_numcases: ['I04', 'I30', 'I43', 'I44'],
        visceral_surgery_numcases: ['06', '07'],
        colon_surgery_numcases: ['G02', 'G12', 'G13', 'G16', 'G17', 'G18'],
        hernia_numcases: ['G08', 'G09', 'G24', 'G25'],
        appendectomy_adult_numcases: ['G22', 'G23'],
        cholecystectomy_numcases: ['H02', 'H05', 'H07', 'H08']
    }

    puts "Load folder #{args.directory}"
    version = args.version
    year = args.year
    hop_cache = hospital_cache()
    hop_not_found = {}

    numcases_by_hospital_and_variable = {}
    hop_by_id = {}

    Dir.entries(args.directory).sort.each do |file|
      next unless file.downcase.end_with?('csv.utf8')

      file_name = File.join(args.directory, file)
      count = `wc -l "#{file_name}"`.to_i  +  1
      pg = ProgressBar.create(total: count, title: "Importing #{file_name}..")

      is_hospital_table = file.include? 'hosp_table'
      csv_contents = CSV.read(file_name, col_sep: ';')
      # skip header
      csv_contents.shift

      csv_contents.each do |row|
        if is_hospital_table
          hop_by_id[row[1].to_i] = row[2]
        else
          next unless version == row[2]

          pg.increment

          hop_id = row[0].to_i
          level = row[3]
          code = row[4]
          numcase = row[5].to_i

          numcases_by_hospital_and_variable[hop_id] = {} if numcases_by_hospital_and_variable[hop_id].nil?

          numcases_by_hospital_and_variable[hop_id][code] = numcase

          if level == 'DRG'
            adrg = code[0..2]
            numcases_by_hospital_and_variable[hop_id][adrg] = 0 if numcases_by_hospital_and_variable[hop_id][adrg].nil?
            numcases_by_hospital_and_variable[hop_id][adrg] += numcase
          end
        end
      end
      pg.finish
    end

    numcases_by_hospital_and_variable.each do |hopid, code_numcases|
      hop = get_hospital hop_cache, hop_by_id[hopid]
      if(hop == nil)
        hop_not_found[hop_by_id[hopid]] = 1
        next
      end

      variables.each do |field_name, codes|
        numcases = 0
        codes.each do |code|
          numcases += code_numcases[code] unless code_numcases[code].nil?
        end

        next if numcases.nil?

        field = hop[field_name] == nil ? {} : hop[field_name].clone
        field[year] = numcases
        hop[field_name] = field
      end

      hop.save!
    end


    puts
    puts "#{hop_not_found.length} hospitals not found in master:"
    puts hop_not_found.keys
    puts

  end

end
