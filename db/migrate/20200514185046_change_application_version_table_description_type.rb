class ChangeApplicationVersionTableDescriptionType < ActiveRecord::Migration[5.2]
  def change
    change_column :application_versions, :description, :text
  end
end
