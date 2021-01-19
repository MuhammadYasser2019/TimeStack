class CreateWeeks < ActiveRecord::Migration[5.2]
  def change
    create_table :weeks do |t|
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end
