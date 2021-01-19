class CreateTimeEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :time_entries do |t|
      t.datetime :date
      t.integer :hours
      t.string :comments
      t.belongs_to :task, index: true, foreign_key: true
      t.belongs_to :week, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
