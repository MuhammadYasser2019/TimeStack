class CreateUserVacationTables < ActiveRecord::Migration[5.2]
  def change
    create_table :user_vacation_tables do |t|
    	t.integer :user_id
      	t.integer :vacation_id
      	t.decimal :days_used, precision: 5, scale: 2
      t.timestamps
    end
  end
end
