namespace :db do
  desc 'Extract Hospitals from Doctors'
  task seed_hospitals: :environment do

    puts "Found #{Doctor.hospital.count} hospitals in doctors"

    Doctor.hospital.each do |hospital|
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
end