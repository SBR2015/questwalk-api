require 'sinatra/base'
require 'active_record'
require 'json'

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || :development)

class Quest < ActiveRecord::Base
end

class App < Sinatra::Base
  def gen_success_message
    {
      status: 'success',  
      message: 'database update completed successfully.'
    }.to_json
  end
  
  def gen_error_message
    {
      status: 'error',
      message: 'database update failed.'
    }.to_json
  end
  
  get '/list' do
    results = {}
    items = []
    Quest.all.each do |quest|
      id = quest.id
      name = quest.name
      item = {}
      item['id'] = id
      item['title'] = name
      items.push(item)
    end
    results = {
      items: items
    }
    results.to_json
  end
  
  post '/list/add' do
    @password = params[:password]
    @title = params[:name]
    newQ = Quest.new
    begin
      if @password != ENV['QW_PASSWORD']
        raise
      end
      newQ.transaction do
        newQ.name = @title
        newQ.save        
      end
      gen_success_message
    rescue ActiveRecord::RecordInvalid => invalid
      gen_error_message
    end
  end
  
  delete '/list/delete/:quest_id' do
    @password = params[:password]
    questid = params[:quest_id]
    begin
      if @password != ENV['QW_PASSWORD']
        raise
      end
      newQ = Quest.find(questid)
      newQ.transaction do
        newQ.destroy
      end
      gen_success_message
    rescue ActiveRecord::RecordNotFound
      gen_error_message
    rescue ActiveRecord::RecordInvalid => invalid
      gen_error_message
    end    
  end
end