class CreateBillingPeriods < ActiveRecord::Migration[5.2]
  def change
    create_table :billing_periods do |t|      
      t.date :start_date
      t.date :end_date
      t.string :status   
      t.timestamps null: false
    end
  end
end
