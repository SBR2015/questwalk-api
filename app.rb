require 'sinatra/base'
require 'active_record'
require 'json'
require 'securerandom'

# model
require './app/model/user'
require './app/model/quest'
require './app/model/activity'

# helper
require './app/helper/basehelper'

# route
require './app/controller/questcontroller'
require './app/controller/activitycontroller'
require './app/controller/usercontroller'

class App < Sinatra::Base
  configure do
    ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || :development)
  end
  
  before do
    @password = params[:api_password]
    content_type 'application/json'
  end

  helpers Sinatra::BaseHelper

  register Sinatra::QuestController
  register Sinatra::ActivityController
  register Sinatra::UserController
end
