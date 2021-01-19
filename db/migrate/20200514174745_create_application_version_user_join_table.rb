class CreateApplicationVersionUserJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_table :users_application_versions do |t|
      t.integer :user_id
      t.integer :application_version_id
    end
  end
end
