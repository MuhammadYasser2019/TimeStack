class CreateApplicationVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :application_versions do |t|
      t.string :version_name
      t.date :start_date
      t.string :platform 
      t.string :description

      t.timestamps null: false
    end
  end
end
