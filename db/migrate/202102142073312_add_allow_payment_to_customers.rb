class AddAllowPaymentToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :allow_payment, :boolean , :default => false    
  end
end
