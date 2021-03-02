module CustomersHelper

	def monthly_invoice_details(billing_period_id, customer_id)  		
  		monthly_invoice_details = InvoiceDetail.where(billing_period_id: billing_period_id,customer_id: customer_id).first
  		return monthly_invoice_details
	end
end
