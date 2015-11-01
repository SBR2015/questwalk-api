class AddExpAndLevelToUsers < ActiveRecord::Migration
  def change
    add_column :users, :exp, :integer
    add_column :users, :level, :integer
  end
end
