class AddStatusToActivites < ActiveRecord::Migration
  def change
    add_column :activities, :done, :bool, :default => false
  end
end
