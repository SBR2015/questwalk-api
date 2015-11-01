class AddUserPhysicalInfo < ActiveRecord::Migration
  def change
    add_column :users, :sex, :string
    add_column :users, :age, :integer
    add_column :users, :height, :float
    add_column :users, :weight, :float
  end
end
