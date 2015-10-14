puts Mongoid.load!(Rails.root.join('config/mongoid.yml'))
Mongo::Logger.logger.level = ::Logger::FATAL