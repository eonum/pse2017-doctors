namespace :create_users do

  desc 'Creating new users for all doctors'
  task doctors: :environment do

    for doc in Doctor

      docId = doc.id.to_s
      mail = docId + "@qualitaetsmedizin.ch"
      if User.where(email: mail).entries == []
        password = (0...8).map { (65 + rand(26)).chr }.join
        user = User.create!(:email => mail, :password => password, :password_confirmation => password , :is_admin => 0)
        puts 'Doctor login created: ' << user.email << '   Password= ' << password

        #Writing Login-Data to CSV
        require "csv"
        CSV.open("loginData.csv","a+") do |csv|
          csv << [doc.name,mail,password]
        end
      end
    end
  end

  desc 'Creating a new admin with password asdf'
  task admin: :environment do
    if User.where(email: "admin@qualitaetsmedizin.ch").entries == []
      User.create!(:email => "admin@qualitaetsmedizin.ch",:password => 'asdf', :password_confirmation => 'asdf', :is_admin => 1)
    end
  end

  desc 'Resets database'
  task reset: :environment do

    User.delete_all()
    User.create!(:email => "admin@qualitaetsmedizin.ch",:password => 'asdf', :password_confirmation => 'asdf', :is_admin => 1)

  end

end


