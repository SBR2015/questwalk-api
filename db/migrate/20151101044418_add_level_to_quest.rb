class AddLevelToQuest < ActiveRecord::Migration
  def change
    add_column :quests, :level, :integer
    add_column :quests, :point, :integer
  end
end
