module Sinatra
  module BaseHelper
    # authenticate with admin password
    # admin password is saved as environmental variable.
    def easyauth
      if @password != ENV['QW_PASSWORD']
        401
      end
    end

    def authenticatebytoken
      @token = request.env['HTTP_AUTHORIZATION_TOKEN']
      @user = User.find_by(token: @token)
    end
  
    def userinfo(user, hasactivity)
      userinfo = {}
      userinfo[:id] = user.id
      userinfo[:username] = user.username
      userinfo[:activities] = user.activities.where(:user_id => user.id) if hasactivity
    
      if @user.nil? == false && @user.id == user.id
        userinfo[:email] = user.email      
        userinfo[:token] = user.token
        userinfo[:sex] = user.sex
        userinfo[:height] = user.height
        userinfo[:weight] = user.weight
        userinfo[:age] = user.age
      end
      userinfo
    end
  
    def activitylist(activities)
      authenticatebytoken
      result = {}
      acts = []
      activities.each do |act|
        item = {}
        item[:quest] = act.quest
        item[:user] = userinfo(act.user, false)
        item[:done] = act.done
        acts.push(item)
      end
      result[:activities] = acts
      result.to_json
    end
  
    def addactivity(quest_id, done)
      newact = Activity.new
      begin
        newact.transaction do
          quest = Quest.find(quest_id)
          newact.user_id = @user.id
          newact.quest_id = quest.id
          newact.done = done
          newact.save
        end
        {
          'message':'Congrats! This activity was added.'
        }.to_json
      rescue
        errormessageresult
      end
    end
  
    def messageresult(successflag, message)
      result = {
        'status': 'error'
      }
      result[:status] = 'success' if successflag == true
      result[:message] = message
      result.to_json
    end
  
    def successmessageresult
      messageresult(true, 'database update completed successfully.')
    end

    def errormessageresult
      messageresult(false, 'database update failed.')
    end
  end
end