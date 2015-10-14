require_relative 'seed_helpers.rb'

namespace :db do
  desc 'Extract Hospitals from Doctors'
  task seed_doctors: :environment do
    Hospital.delete_all

    file = Rails.root.join('data', 'medical', 'doctors.csv')
    count = `wc -l #{file}`.to_i

    pg = ProgressBar.create(total: count, title: 'Indexing Doctor Fields')

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

    fields_to_fmh = docfield_to_fmh

    pg = ProgressBar.create(total: d_hash.size, title: 'Importing Doctors')
    d_hash.each do |k, v|
      row = doc_file[v[:line]].split(';')
      fs_codes = fields_to_fmh.values_at(*v[:fields])
      Doctor.create do |d|
        d.doc_id = row[0].strip.to_i
        d.name = row[1].strip
        d.title = (row[2]||'').strip
        d.address = (row[3]||'').strip
        d.email = (row[4]||'').strip
        d.phone1 = (row[5]||'').strip
        d.phone2 = (row[6]||'').strip
        d.canton = (row[7]||'').strip
        d.docfields = v[:fields]
        d.specialities = Speciality.in(code: fs_codes.compact.flatten)
        d.location = [row[9].strip.to_f, row[10].strip.to_f] # long/lat
      end

      pg.increment
    end

    # Extract hospitals from doctors
    Doctor.where(docfields: 'spital').each do |d|
      Hospital.create do |h|
        h.doc_id = d.doc_id
        h.name = d.name
        h.title = d.title
        h.address = d.address
        h.phone1 = d.phone1
        h.phone2 = d.phone2
        h.email = d.email
        h.canton = d.canton
        h.location = d.location
      end
      # Delete hospital from doctors
      d.destroy
    end

    Doctor.create_indexes
    Hospital.create_indexes
  end


  task all: :environment do
    Rake::Task['db:mongoid:remove_indexes'].execute
    Rake::Task['db:seed_doctors'].execute
    Rake::Task['db:mongoid:create_indexes'].execute
  end

end
