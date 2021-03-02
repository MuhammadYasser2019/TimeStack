class AddOutstandingAmountToInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_details, :outstanding_amount, :float 
    add_column :invoice_details, :total_amount, :float     
    add_column :invoice_details, :billing_period_id, :integer 
  end
end
