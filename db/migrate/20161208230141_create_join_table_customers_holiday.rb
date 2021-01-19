class CreateJoinTableCustomersHoliday < ActiveRecord::Migration[5.2]
  def change
    create_join_table :customers, :holidays do |t|
       t.integer :customer_id
       t.integer :holiday_id
       t.index [:customer_id, :holiday_id]
       t.index [:holiday_id, :customer_id]
    end
  end
end
