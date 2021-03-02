class AddPaymentConfirmationIdToInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_details, :payment_confirmation_id, :string 
    add_column :invoice_details, :start_date, :date 
    add_column :invoice_details, :end_date, :date 
  end
end
