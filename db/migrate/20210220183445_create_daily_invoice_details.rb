class CreateDailyInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_invoice_details do |t|      
      t.integer :active_user
      t.float :amount_per_user
      t.float :daily_amount
      t.integer :billing_period_id          
      t.integer :customer_id
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
