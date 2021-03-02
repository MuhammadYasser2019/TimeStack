class UsioPayment< ApplicationRecord 
 @@REGISTRATION_AMOUNT = "0.00"
 
 def self.register_new_card(card_number, card_type, cvv, exp_date, first_name, last_name, email, address, city, state, zip)
 payload = {
 "CardNumber": card_number,
 "CardType": card_type,
 "CVV": cvv,
 "ExpDate": exp_date,
 "Amount": @@REGISTRATION_AMOUNT,
 "FirstName": first_name,
 "LastName": last_name,
 "EmailAddress": email,
 "Address1": address,
 "City": city,
 "State": state,
 "Zip": zip,
 "AuthOnly": true
 } 
 res = make_api_request(url: "https://payments.usiopay.com/2.0/payments.svc/JSON/SubmitCCPayment", payload: payload)
 response = {
 "success": false,
 }
 
 response[:success] = res["Status"] == "success"
 response[:token] = res["Confirmation"]
 response[:message] = res["Message"]
 response[:amount] = @@REGISTRATION_AMOUNT
 
 response
 end
 
 def self.submit_token_payment(token, amount, description)
 payload = {
 "Amount": amount.to_s,
 "Token": token,
 "Description": description
 }
 
 res = make_api_request(url: "https://payments.usiopay.com/2.0/payments.svc/JSON/SubmitTokenPayment", payload: payload)
 
 response = {
 "success": false,
 }
 
 response[:success] = res["Status"] == "success"
 response[:confirmation_id] = res["Confirmation"]
 response[:message] = res["Message"]
 response[:amount] = amount
 response
 end
 
 def self.void_payment(confirmation_id, amount)
 payload = {
 "Amount": amount,
 "ConfirmationID": confirmation_id
 }
 
 res = make_api_request(url: "https://payments.usiopay.com/2.0/payments.svc/JSON/SubmitCCVoid", payload: payload)
 
 response = {
 "success": false,
 }
 
 response[:success] = res["Status"] == "success"
 response[:confirmation_id] = res["Confirmation"]
 response[:message] = res["Message"]
 response[:amount] = amount
 
 response
 end
 
 private 
 
 def self.make_api_request(url: "", payload: {})
 payload["MerchantID"] =  ENV['MERCHANT_ID']
 payload["Login"] =   ENV['USIO_LOGIN']
 payload["Password"] = ENV['USIO_PASSWORD']
 
 res = RequestHelper.make_post_request(url: url, payload: payload)
 result = {
 "Confirmation": "",
 "Message": "Failure.",
 "Status": "failure"
 }
 
 if(res[:status])
 result = JSON.parse(res[:response])
 end
 
 result
 end
 
 def self.usio_merchant_id
 Rails.application.secrets[:usio_merchant_id]
 end
 
 def self.usio_username
 Rails.application.secrets[:usio_username]
 end
 
 def self.usio_password
 Rails.application.secrets[:usio_password]
 end
 
 def self.usio_base_url
 Rails.application.secrets[:usio_url]
 end
end
