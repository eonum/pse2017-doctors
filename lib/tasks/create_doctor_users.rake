namespace :create_doctor_users do

  desc 'Creating new users for all doctors'

  task createDoctorUsers: :environment do
    for doc in Doctor

      docId = doc.id.to_s
      mail = docId + "@qualitaetsmedizin.ch"
      password = (0...8).map { (65 + rand(26)).chr }.join
      user = User.create!(:email => mail, :password => password, :password_confirmation => password)
      puts 'Doctor login created: ' << user.email << '   Password= ' << password
    end
  end

end
