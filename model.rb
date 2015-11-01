require 'active_record'
require './model/user'
require './model/quest'

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || :development)
