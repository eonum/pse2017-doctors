# Orange-Proton 2.0

This is a 100% rewrite of the 2012 PSE Project 'Orange-Proton'

## Installation

### Seeding
1. Run `rake db:seed:all` to seed all necessary data. MongoDB indices will be created automatically.
2. Startup an ElasticSearch instance and run `rake search:index:create` to create the necessary indices. Run `rake search:reindex` to start indexing process.
An 'op2_' prefix will be used for all indices created in this process. This can be changed in the `mongoid.rb` initializer.