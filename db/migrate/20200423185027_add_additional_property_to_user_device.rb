class AddAdditionalPropertyToUserDevice < ActiveRecord::Migration[5.2]
  def change
    add_column :user_devices, :device_name, :string
  end
end
