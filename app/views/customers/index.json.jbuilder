json.array!(@customers) do |customer|
  json.extract! customer, :id, :name, :address, :city, :state, :zipcode
  json.url customer_url(customer, format: :json)
end
