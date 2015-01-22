require 'csv'
require_relative 'seed_helpers.rb'

namespace :db do
  desc 'Extract Hospitals from Doctors'
  task seed_hospitals: :environment do
    Doctor.delete_all
    puts "Found #{Doctor.hospital.count} hospitals in doctors"

    Doctor.with(database: 'orange-proton').hospital.each do |hospital|
      Hospital.with(database: 'mongoid_test_development').create do |new_hospital|
        new_hospital.doc_id = hospital.doc_id
        new_hospital.name = hospital.name
        new_hospital.title = hospital.title
        new_hospital.address = hospital.address
        new_hospital.phone1 = hospital.phone1
        new_hospital.phone2 = hospital.phone2
        new_hospital.email = hospital.email
        new_hospital.canton = hospital.canton
        new_hospital.lat = hospital.lat
        new_hospital.long = hospital.long
      end

      hospital.destroy
    end
  end

  desc 'Extract Hospitals from Doctors'
  task seed_doctors: :environment do
    Doctor.delete_all

    puts "Found #{Doctor.with(database: 'orange-proton').count} doctors"

    Doctor.with(database: 'orange-proton').each do |doctor|
      Doctor.with(database: 'mongoid_test_development').create do |new_doctor|
        new_doctor.doc_id = doctor.doc_id
        new_doctor.name = doctor.name
        new_doctor.title = doctor.title
        new_doctor.address = doctor.address
        new_doctor.phone1 = doctor.phone1
        new_doctor.phone2 = doctor.phone2
        new_doctor.email = doctor.email
        new_doctor.canton = doctor.canton
        new_doctor.lat = doctor.lat
        new_doctor.long = doctor.long
        new_doctor.docfield = doctor.docfield
      end
    end
  end

  task geocode: :environment do
    [Hospital, Doctor].each do |model|
      model.not_geocoded.each do |instance|
        instance.location = [instance.long, instance.lat]
        instance.save
      end
    end
  end

  task consolidate_specialities: :environment do
    doctors = Doctor.exists(docfields: false)

    pg = ProgressBar.create(total: doctors.count)

    doctors.each do |d|
      fields = Doctor.where(title: d.title, name: d.name).map(&:docfield)
      d.docfields = fields
      d.save
      pg.increment
    end
  end

  'Seed FMH Specialties with fallbacks and compounds'
  task seed_specialities: :environment do
    Speciality.delete_all

    file = Rails.root.join('data','fmh','fmh_names.csv')
    count = `wc -l #{file}`.to_i

    pg = ProgressBar.create(total: count)

    # Seed names
    CSV.foreach file, col_sep: ";" do |row|
      code = row[0].to_i

      Speciality.create(code: code) do |fmh|
        fmh.name_translations = { de: row[1], en: row[2], fr: row[3], it: row[4] }
      end

      pg.increment
    end

    # Seed fallbacks
    fallbacks = {}
    CSV.foreach Rails.root.join('data', 'fmh', 'fmh_fallbacks.csv'), col_sep: ';' do |row|
      code = row[0].to_i
      fallback = row[1].to_i
      fallbacks[code] = fallback
    end

    fallbacks.each_key do |k|
      fmh_fallbacks = []
      code = k
      while not fallbacks[code].nil?
        code = fallbacks[code]
        fmh_fallbacks << code
      end

      # Add Allgemeinmedizin
      fmh_fallbacks << 5 unless fmh_fallbacks.include? 5

      fmh = Speciality.find_by(code: k)
      fmh.fallbacks = fmh_fallbacks
      fmh.save
    end

    # Seed compounds
    CSV.foreach Rails.root.join('data', 'fmh', 'fmh_compounds.csv'), col_sep: ';' do |row|
      code = row[0].to_i
      compounds = [row[1].to_i, row[2].to_i]

      fmh = Speciality.find_by(code: code)
      fmh.compounds = compounds
      fmh.save
    end

  end

  task seed_doctor_specs: :environment do
    db = Moped::Session.new(['127.0.0.1:27017'])
    db.use 'orange-proton'

    Doctor.each do |d|
      fields = d.docfields
      fmhs = db[:docfield_to_fmh].find({ docfield: { "$in" => fields } }).to_a
      fs_codes = fmhs.map { |f| f['fs_code']}
      d.speciality_ids = fs_codes
      d.save
    end
  end

  namespace :seed do

    desc 'Seed ICD Codes'
    task icd: :environment do
      # 0code;text_de;text_fr;text_it;text_en;5version;inclusions_de;inclusions_fr;inclusions_it;exclusions_de;10exclusions_fr;
      # 11exclusions_it;synonyms_de;synonyms_fr;synonyms_it;15subclasses;16most_relevant_drgs

      file = Rails.root.join('data','icd', 'icdgm2014.csv')
      count = `wc -l #{file}`.to_i

      pg = ProgressBar.create(total: count)

      CSV.foreach file, headers: true, col_sep: ";" do |row|
        code = row[0]
        version = row[5]
        drgs = parse_psql_array(row[16])
        subclasses = parse_psql_array(row[15])

        icd = Icd.create(code: code, version: version, drgs: drgs, subclasses: subclasses)
        icd.text_translations = { de: row[1], fr: row[2], it: row[3], en: row[4] }
        icd.inclusiva_translations = {
            de: parse_psql_array(row[6]),
            fr: parse_psql_array(row[7]),
            it: parse_psql_array(row[8])
        }
        icd.exclusiva_translations = {
            de: parse_psql_array(row[9]),
            fr: parse_psql_array(row[10]),
            it: parse_psql_array(row[11])
        }
        icd.synonyms_translations = {
            de: parse_psql_array(row[12]),
            fr: parse_psql_array(row[13]),
            it: parse_psql_array(row[14])
        }
        icd.save

        pg.increment
      end
    end

    desc 'Seed CHOP Codes'
    task chop: :environment do
      Chop.delete_all
      #0"code"|"code_short"|"text_de"|"text_fr"|"text_it"|5"version"|"inclusions_de"|"inclusions_fr"|"inclusions_it"|
      # "exclusions_de"|10"exclusions_fr"|"exclusions_it"|"descriptions_de"|"descriptions_fr"|"descriptions_it"|"most_relevant_drgs"
      file =  Rails.root.join('data','chop', 'chop2015.csv')
      count = `wc -l #{file}`.to_i

      pg = ProgressBar.create(total: count)

      CSV.foreach file, headers: true, col_sep: "|" do |row|
        code = row[0]
        code_short = row[1]
        version = row[5]
        drgs = parse_psql_array(row[15])

        chop = Chop.create(code: code, code_short: code_short, version: version, drgs: drgs)
        chop.text_translations = { de: row[3], fr: row[2], it: row[4] }
        chop.inclusiva_translations = {
            de: parse_psql_array(row[6]),
            fr: parse_psql_array(row[7]),
            it: parse_psql_array(row[8])
        }
        chop.exclusiva_translations = {
            de: parse_psql_array(row[9]),
            fr: parse_psql_array(row[10]),
            it: parse_psql_array(row[11])
        }
        chop.save

        pg.increment
      end
    end

    desc 'Seed MDC Codes'
    task mdc: :environment do
      Mdc.delete_all
      # version;code;text_de;text_it;text_fr;prefix

      file = Rails.root.join('data','mdc', 'mdc40.csv')
      count = `wc -l #{file}`.to_i

      pg = ProgressBar.create(total: count)

      CSV.foreach file, headers: true, col_sep: ";" do |row|
        mdc = Mdc.create(code: row[1], version: row[0], prefix: row[5])
        mdc.text_translations = { de: row[2], it: row[3], fr: row[4] }
        mdc.save

        pg.increment
      end
    end

    desc 'Seed Reputations'
    task reputation: :environment do

      Hospital.each do |h|
        h.ratings.delete_all
        h.save
      end

      file = Rails.root.join('data','medical', 'reputation_icd.csv')
      count = `wc -l #{file}`.to_i

      pg = ProgressBar.create(total: count)

      CSV.foreach file, col_sep: ";" do |row|
        h = Hospital.where(doc_id: row[0].to_i).first
        h.ratings.build(code: row[1], level: row[2])
        h.save

        pg.increment
      end

    end

  end

end