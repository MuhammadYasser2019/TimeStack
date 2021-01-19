class AddSharedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :shared, :boolean
  end
end
