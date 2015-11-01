require 'sinatra/base'
require 'active_record'
require 'json'
require 'securerandom'
require './model'

class App < Sinatra::Base
  before do
    @password = params[:api_password]
    content_type 'application/json'
  end
  
  helpers do
    # authenticate with admin password
    # admin password is saved as environmental variable.
    def easyauth
      if @password != ENV['QW_PASSWORD']
        raise
      end
    end
    
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
    }.to_json
  end
  
  post '/list/add' do
    easyauth
    @title = params[:name]
    newQ = Quest.new
    begin
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
    easyauth
    questid = params[:quest_id]
    begin
      quest = Quest.find(questid)
      quest.transaction do
        quest.destroy
      end
      gen_success_message
    rescue ActiveRecord::RecordNotFound
      gen_error_message
    rescue ActiveRecord::RecordInvalid => invalid
      gen_error_message
    end    
  end

  # create user
  post '/user/create' do
    user = User.find_by(username: params[:username])
    if user.nil?
      user = User.new(:username => params[:username], :password => params[:password], :password_confirmation => params[:password])
      begin
        if user.save
          gen_success_message
        else
          gen_error_message
        end
      rescue
        gen_error_message
      end
    else
      result = {}
      result[:message] = "that user already exists"
      result.to_json
    end
  end
  
  # get user token
  post '/user/signin' do
    user = User.find_by(username: params[:username])
    if user.nil?
      {
        'message' => 'user not found'
      }.to_json
    elsif user.authenticate(params[:password])
      token = SecureRandom.hex(16)
      user.token = token
      user.save
      {
        'token' => token,
      }.to_json
    else
      401
    end
  end
  
  # confirm whether user is valid
  get '/user/auth' do
    token = request.env['HTTP_AUTHORIZATION_TOKEN']
    user = User.find_by(token: token)
    if user.nil?
      401
    else
      {
        'message':'user is valid'
      }.to_json
    end    
  end
  
  # remove user token
  post '/user/signout' do
    token = request.env['HTTP_AUTHORIZATION_TOKEN']
    user = User.find_by(token: token)
    if user.nil?
      404
    else
      user.token = nil
      user.save
      {
        'message':'user logged out'
      }.to_json
    end    
  end
end
