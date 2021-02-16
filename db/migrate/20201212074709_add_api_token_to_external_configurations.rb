class AddApiTokenToExternalConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :external_configurations, :api_token, :string 
    add_column :external_configurations, :user_id, :int
  end
end
