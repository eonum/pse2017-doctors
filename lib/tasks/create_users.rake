require 'csv'

namespace :create_users do

  desc 'Creating new users for all doctors'
  task doctors: :environment do
    existing_users = User.all.map {|u| u.email}

    users = []
    CSV.open('loginData.csv','a+') do |csv|
      for doc in Doctor
        docId = doc.id.to_s
        mail = docId + '@qualitaetsmedizin.ch'
        unless existing_users.include? mail
          password = (0...8).map { (65 + rand(26)).chr }.join
          users << {:email => mail, :password => password, :password_confirmation => password , :is_admin => false}
          puts 'Doctor login created: ' << mail << '   Password= ' << password

          # Writing Login-Data to CSV
          csv << [doc.name,mail,password,doc.email]
        end
      end
    end
    User.create(users)
  end

  desc 'Creating a new admin with password asdf or upgrades the current one to really count as an admin'
  task admin: :environment do
    if User.where(email: 'admin@qualitaetsmedizin.ch').entries == []
      User.create!(:email => 'admin@qualitaetsmedizin.ch',:password => 'asdf', :password_confirmation => 'asdf', :is_admin => true)
    else
      User.where(:email => 'admin@qualitaetsmedizin.ch').update_all(:is_admin => true)
    end
  end

  desc 'Resets database'
  task reset: :environment do

    User.delete_all()
    File.delete('loginData.csv') if File.exist?('loginData.csv')
    User.create!(:email => 'admin@qualitaetsmedizin.ch',:password => 'asdf', :password_confirmation => 'asdf', :is_admin => true)

  end

end


