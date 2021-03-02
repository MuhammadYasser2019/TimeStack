class CreatePaymentDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_details do |t|
      t.string  :card_number
      t.text    :token
      t.text    :card_type      
      t.string  :expire_date
      t.boolean :active, :default => false  
      t.boolean :default_card
      t.integer :customer_id
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
