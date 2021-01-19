class AddUserDeviceTable < ActiveRecord::Migration[5.2]
  def change
    create_table :user_devices do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :user_token
      t.string :device_id
      t.string :platform
    end
  end
end
