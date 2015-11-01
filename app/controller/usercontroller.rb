module Sinatra
  module UserController
    def self.registered(app)
      # create user
      app.post '/user/create' do
        user = User.find_by(username: params[:username])
        if user.nil?
          user = User.new(:username => params[:username], :password => params[:password], :password_confirmation => params[:password])
          begin
            if user.save
              successmessageresult
            else
              errormessageresult
            end
          rescue
            errormessageresult
          end
        else
          messageresult(false, "that user already exists")
        end
      end
  
      # get user token
      app.post '/user/signin' do
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
      app.get '/user/:username' do
        authenticatebytoken
        user = User.joins(:activities).find_by(username: params[:username])
        if user.nil?
          404
        else
          userinfo(user, true).to_json
        end    
      end
  
      # remove user token
      app.post '/user/signout' do
        authenticatebytoken
        if @user.nil?
          404
        else
          @user.token = nil
          @user.save
          {
            'message':'user logged out'
          }.to_json
        end    
      end
    end
  end
  register UserController
end