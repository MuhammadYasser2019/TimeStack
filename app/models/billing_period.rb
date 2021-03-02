class BillingPeriod< ApplicationRecord	
  belongs_to :customers  
  has_many :daily_invoice_details
  has_many :invoice_details

  STATUS={
  	"Active" => "active",
  	"Close" => "close"
  }
end
