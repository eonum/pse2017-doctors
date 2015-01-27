puts Mongoid.load!(Rails.root.join('config/mongoid.yml'))
Mongoid::Elasticsearch.prefix = 'my_app'