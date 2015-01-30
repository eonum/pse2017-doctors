puts Mongoid.load!(Rails.root.join('config/mongoid.yml'))
Mongoid::Elasticsearch.prefix = 'op2_'