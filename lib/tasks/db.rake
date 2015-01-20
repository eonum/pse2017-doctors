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

  task seed_specialities: :environment do
    Speciality.delete_all

    db = Moped::Session.new(['127.0.0.1:27017'])
    db.use 'orange-proton'

    db[:fmh_names].find.to_a.each do |doc|
      Speciality.create do |s|
        s.code = doc[:code]
        %i(de fr it en).each do |lang|
          I18n.locale = lang
          s.name = doc[lang]
        end
      end
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
      # 0code|text_fr|text_de|text_it|version|5inclusions_de|inclusions_fr|inclusions_it|exclusions_de|exclusions_fr|10exclusions_it|
      # 11descriptions_de|descriptions_fr|descriptions_it|14most_relevant_drgs
      file =  Rails.root.join('data','chop', 'chop2015.csv')
      count = `wc -l #{file}`.to_i

      pg = ProgressBar.create(total: count)

      CSV.foreach file, headers: true, col_sep: "|" do |row|
        code = row[0]
        version = row[4]
        drgs = parse_psql_array(row[14])

        chop = Chop.create(code: code, version: version, drgs: drgs)
        chop.text_translations = { de: row[2], fr: row[1], it: row[3] }
        chop.inclusiva_translations = {
            de: parse_psql_array(row[5]),
            fr: parse_psql_array(row[6]),
            it: parse_psql_array(row[7])
        }
        chop.exclusiva_translations = {
            de: parse_psql_array(row[8]),
            fr: parse_psql_array(row[9]),
            it: parse_psql_array(row[10])
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

      CSV.foreach file, headers: true, col_sep: ";" do |row|
        mdc = Mdc.create(code: row[1], version: row[0], prefix: row[5])
        mdc.text_translations = { de: row[2], it: row[3], fr: row[4] }
        mdc.save
      end
    end

  end

end