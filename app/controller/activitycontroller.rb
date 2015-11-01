module Sinatra
  module ActivityController
    def self.registered(app)
      app.get '/activity/list' do
        activities = Activity.joins(:quest).joins(:user).all
        activitylist(activities)
      end
  
      app.get '/activity/list/:username' do
        user = User.find_by(:username => params[:username])
        if user.nil?
          404
        else
          activities = Activity.joins(:quest).joins(:user).where(:user_id => user.id)
          activitylist(activities)
        end
      end
  
      app.post '/activity/add/:quest_id' do
        authenticatebytoken
        act = Activity.where(:user_id => @user.id, :quest_id => params[:quest_id]).first
        if act.nil?
          addactivity(params[:quest_id], false)
        else
          messageresult(false, 'this activity already exists.')
        end
      end
  
      app.put '/activity/update/:quest_id/:done_or_undone' do
        authenticatebytoken
        act = Activity.where(:user_id => @user.id, :quest_id => params[:quest_id]).first
        if act.nil?
          addactivity(params[:quest_id], (params[:done_or_undone] == 'done'))
        else
          act.done = (params[:done_or_undone] == 'done')
          if act.save
            messageresult(true, 'this activity was updated.')
          else
            errormessageresult
          end
        end  
      end
  
      app.delete 'activity/delete/:quest_id' do
        authenticatebytoken
        act = Activity.where(:user_id => @user.id, :quest_id => params[:quest_id]).first
        if act.nil?
          messageresult(false, 'this activity not found.')
        elsif
          begin
            quest.transaction do
              act.destroy
            end
            messageresult(true, 'This activity was deleted. You can try it again!')
          rescue
            errormessageresult
          end
        end
      end  
    end  
  end
  register ActivityController
end