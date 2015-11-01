require 'sinatra/base'

module Sinatra
  module QuestController
    def self.registered(app)
      app.get '/quest/list' do
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

      app.post '/quest/list/add' do
        easyauth
        @title = params[:name]
        newQ = Quest.new
        begin
          newQ.transaction do
            newQ.name = @title
            newQ.save        
          end
          successmessageresult
        rescue
          errormessageresult
        end
      end

      app.delete '/quest/list/delete/:quest_id' do
        easyauth
        questid = params[:quest_id]
        begin
          quest = Quest.find(questid)
          quest.transaction do
            quest.destroy
          end
          successmessageresult
        rescue
          errormessageresult
        end    
      end
    end
  end
  register QuestController
end