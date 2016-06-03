# qualimed-hospitals

This project aims to provide a list of the nearest Swiss hospitals from a certain specialty annotated with different quality indicators. The typical user is a patient without a medical education.
The provided quality indicators are released by the Federal Office of Public Health FOPH. The site administrator should be able to add new variables/indicators and specialties in a generic fashion without rewriting the application.

## Installation

### Seeding
1. Run `rake db:seed:all` to seed all necessary data. MongoDB indices will be created automatically.

### Create doctor logins and admin or reset the user-database
1. Run 'rake create_users:doctors' to create a user for every
doctor in the database. The login-Date gets saved to the file loginData.csv
in the qualimed_hospitals directory
2. Run 'rake create_users:admin' to create an admin-entry to the database
with the default password 'asdf'
If you already have an admin-user this will upgrade it and add all newly needed rights
3. Run 'rake create_users:reset' to delete all users and create an admin user
with the default password 'asdf'

### Add icons to comparisons
1. Run 'rake comparisons:add_icons' to add icons to all seven comparisons currently existing on qm1.ch
2. If a comparison doesn't have an icon set yet, login as an admin and go to comparison.
3. Edit the comparison you want to have an icon. In the edit form you can either select
an image that is already on the server or add raw html code that will be shown then, for example
to add a favicon

### Change the admin user password for production
1. Run `rails c`
2. In the console:
```ruby
admin = User.first
admin.password = 'new_password_very_secret'
admin.password_confirmation = 'new_password_very_secret'
admin.save
```



