# qualimed-hospitals

This project aims to provide a list of the nearest Swiss hospitals from a certain specialty annotated with different quality indicators. The typical user is a patient without a medical education.
The provided quality indicators are released by the Federal Office of Public Health FOPH. The site administrator should be able to add new variables/indicators and specialties in a generic fashion without rewriting the application.

## Installation

### Seeding
1. Run `rake db:seed:all` to seed all necessary data. MongoDB indices will be created automatically.

### Change the admin user password for production
1. Run `rails c`
2. In the console:
```ruby
admin = User.first
admin.password = ´new_password_very_secret'
admin.password_confirmation = 'new_password_very_secret'
admin.save
```



