class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :name
      t.belongs_to :customer, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
