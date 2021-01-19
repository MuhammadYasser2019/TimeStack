class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :code
      t.string :description
      t.belongs_to :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
