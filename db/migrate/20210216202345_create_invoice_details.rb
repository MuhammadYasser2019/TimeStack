class CreateInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_details do |t|      
      t.string  :attachment 
      t.string :status
      t.integer :active_user
      t.string :amount_per_user
      t.date :paid_date
      t.date :invoice_date
      t.boolean :active, :default => false        
      t.integer :customer_id
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
