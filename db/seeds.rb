# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts 'SETTING UP ADMIN USER LOGIN'
user = User.create!(:username => 'admin', :email => 'admin@qualitaetsmedizin.ch', :password => 'change_me', :password_confirmation => 'change_me')
puts 'Admin login created: ' << user.username