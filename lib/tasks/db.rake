require 'csv'
require_relative 'seed_helpers.rb'

namespace :search do
  namespace :index do

    task remove: :environment do
      [Icd, Chop, Hospital, Doctor, Speciality].each do |model|
        model.es.index.delete
      end
    end

    task create: :environment do
      [Icd, Chop, Hospital, Doctor, Speciality].each do |model|
        model.es.index.create
      end
    end
  end

  task reindex: :environment do
    [Icd, Chop, Hospital, Doctor, Speciality].each do |model|
      model.es.index_all
    end
  end
end

namespace :db do

  desc 'Extract Hospitals from Doctors'
  task seed_doctors: :environment do
    Doctor.delete_all
    Hospital.delete_all

    file = Rails.root.join('data','medical','doctors.csv')
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
        d_hash[name+title] = { line: index, fields: [field]}
      end

      pg.increment
    end

    fields_to_fmh = docfield_to_fmh

    pg = ProgressBar.create(total: d_hash.size, title: 'Importing Doctors')
    d_hash.each do |k,v|
      row = doc_file[v[:line]].split(';')
      fs_codes = fields_to_fmh.values_at(*v[:fields])
      Doctor.create do |d|
        d.doc_id   = row[0].strip.to_i
        d.name     = row[1].strip
        d.title    = (row[2]||'').strip
        d.address  = (row[3]||'').strip
        d.email    = (row[4]||'').strip
        d.phone1   = (row[5]||'').strip
        d.phone2   = (row[6]||'').strip
        d.canton   = (row[7]||'').strip
        d.docfields = v[:fields]
        d.specialities = Speciality.in(code: fs_codes.compact.flatten)
        d.location = [row[9].strip.to_f, row[10].strip.to_f] # long/lat
      end

      pg.increment
    end

    # Extract hospitals from doctors
    Doctor.where(docfields: 'spital').each do |d|
      Hospital.create do |h|
        h.doc_id  = d.doc_id
        h.name    = d.name
        h.title   = d.title
        h.address = d.address
        h.phone1  = d.phone1
        h.phone2  = d.phone2
        h.email   = d.email
        h.canton  = d.canton
        h.location = d.location
      end
      # Delete hospital from doctors
      d.destroy
    end

    Doctor.create_indexes
    Hospital.create_indexes
  end

  'Seed FMH Specialties with fallbacks and compounds'
  task seed_specialities: :environment do
    Speciality.delete_all

    file = Rails.root.join('data','fmh','fmh_names.csv')
    count = `wc -l #{file}`.to_i

    pg = ProgressBar.create(total: count, title: 'Specialities')

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

    Speciality.create_indexes
  end

  task seed_keywords: :environment do

    Speciality.each do |s|
      s.keywords.clear
    end

    Keyword.delete_all

    # Seed keywords
    files = {
        chop: Rails.root.join('data', 'chop', 'chop_dictionary.csv'),
        icd: Rails.root.join('data', 'icd', 'icd_dictionary.csv')
    }

    files.each do |k, file|
      IO.foreach file do |line|
        row = line.split(',')

        keyword = row[0].downcase
        exclusiva = row[1..2].reject(&:empty?).reject{ |e| e == "\n" }
        fs_codes = row[3..-1].reject(&:empty?).reject{ |e| e == "\n" }.map(&:to_i)

        #puts keyword + ': ' + fs_codes.inspect
        fs_codes.each do |code|
          fmh = Speciality.find_by(code: code)

          fmh.keywords.create(keyword: keyword, exclusiva: exclusiva, type: k.to_s)
        end
      end
    end
  end

  namespace :seed do

    desc 'Seed ICD Codes'
    task icd: :environment do
      Icd.destroy_all
      # 0code;text_de;text_fr;text_it;text_en;5version;inclusions_de;inclusions_fr;inclusions_it;exclusions_de;10exclusions_fr;
      # 11exclusions_it;synonyms_de;synonyms_fr;synonyms_it;15subclasses;16most_relevant_drgs

      file = Rails.root.join('data','icd', 'icdgm2014.csv')
      count = `wc -l #{file}`.to_i

      pg = ProgressBar.create(total: count, title: 'ICD')

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
      Chop.destroy_all
      #0"code"|"code_short"|"text_de"|"text_fr"|"text_it"|5"version"|"inclusions_de"|"inclusions_fr"|"inclusions_it"|
      # "exclusions_de"|10"exclusions_fr"|"exclusions_it"|"descriptions_de"|"descriptions_fr"|"descriptions_it"|"most_relevant_drgs"
      file =  Rails.root.join('data','chop', 'chop2015.csv')
      count = `wc -l #{file}`.to_i

      pg = ProgressBar.create(total: count, title: 'CHOP')

      CSV.foreach file, headers: true, col_sep: "|" do |row|
        code = row[0]
        code_short = row[1]
        version = row[5]
        drgs = parse_psql_array(row[15])

        chop = Chop.create(code: code, code_short: code_short, version: version, drgs: drgs)
        chop.text_translations = { de: row[2], fr: row[3], it: row[4] }
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
      Mdc.destroy_all
      # version;code;text_de;text_it;text_fr;prefix

      file = Rails.root.join('data','mdc', 'mdc40.csv')
      count = `wc -l #{file}`.to_i

      pg = ProgressBar.create(total: count, title: 'MDC')

      CSV.foreach file, headers: true, col_sep: ";" do |row|
        mdc = Mdc.create(code: row[1], version: row[0], prefix: row[5])
        mdc.text_translations = { de: row[2], it: row[3], fr: row[4] }
        mdc.save

        pg.increment
      end

      # Seed Mdc Specialities
      IO.foreach(Rails.root.join('data','relations','mdc_to_fmh.csv')) do |line|
        row = line.split(';')
        #puts row.inspect
        fs_code = row[0].to_i
        mdc_code = row[1]

        s = Speciality.find_by(code: fs_code)
        s.mdcs << Mdc.find_by(code: mdc_code)
        s.save
      end
    end

    desc 'Seed Hospital Ratings'
    task rating: :environment do

      Hospital.each do |h|
        h.ratings.destroy_all
        h.save
      end

      file = Rails.root.join('data','medical', 'reputation_icd.csv')
      count = `wc -l #{file}`.to_i

      pg = ProgressBar.create(total: count, title: 'Hospital Ratings')

      CSV.foreach file, col_sep: ";" do |row|
        h = Hospital.find_by(doc_id: row[0].to_i)
        h.ratings.create(code: row[1], level: row[2])

        pg.increment
      end
    end

    desc 'Seed Thesaurs'
    task thesaur: :environment do
      Thesaur.delete_all

      IO.foreach(Rails.root.join('data','relations','thesaur_to_icd.csv')) do |line|
        row = line.split(';')
        thesaur = row[0]
        icds = row[1..-2]

        Thesaur.create(name: thesaur, codes: icds)
      end

      IO.foreach(Rails.root.join('data','relations','thesaur_to_fmh.csv')) do |line|
        row = line.split(';')
        fs_code = row[0].to_i
        thesaur = row[1]

        t = Thesaur.find_by(name: thesaur)
        t.specialities << Speciality.find_by(code: fs_code)
        t.save
      end
    end

    desc 'Seed Ranges'
    task range: :environment do
      FieldRange.delete_all

      # ICD Ranges
      IO.foreach(Rails.root.join('data','icd','icd_ranges.csv')) do |line|
        row = line.split(';')

        level = row[0].to_i
        beginning = row[1]
        ending = row[2]
        name = row[3]

        fs_codes = row[4..-2].map(&:to_i)

        FieldRange.create(type: 'icd', name: name, beginning: beginning, ending: ending) do |range|
          range.specialities = Speciality.in(code: fs_codes).to_a
        end
      end

      # Chop Ranges
      IO.foreach(Rails.root.join('data','chop','chop_ranges.csv')) do |line|
        row = line.split(';')

        level = row[0].to_i
        beginning = row[1]
        ending = row[2]
        name = row[3]

        fs_codes = row[4..-2].map(&:to_i)

        FieldRange.create(type: 'chop', name: name, beginning: beginning, ending: ending) do |range|
          range.specialities = Speciality.in(code: fs_codes).to_a
        end
      end
    end

    task all: :environment do
      Rake::Task['db:mongoid:remove_indexes'].execute

      Rake::Task['db:seed_specialities'].execute
      Rake::Task['db:seed_doctors'].execute
      Rake::Task['db:seed_keywords'].execute
      Rake::Task['db:seed:icd'].execute
      Rake::Task['db:seed:chop'].execute
      Rake::Task['db:seed:mdc'].execute
      Rake::Task['db:seed:rating'].execute
      Rake::Task['db:seed:thesaur'].execute
      Rake::Task['db:seed:range'].execute

      Rake::Task['db:mongoid:create_indexes'].execute
    end

  end
end