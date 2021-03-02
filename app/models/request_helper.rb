class RequestHelper 
	@@TIMEOUT = 10 
	def self.execute_request (url: "" , method: :get, payload:{}) 
		result = { response: nil , status: false } 
		begin 
			res = RestClient::Request.execute(method: method, url: url, payload: payload.to_json, headers: {accept: :json, content_type: :json}, timeout: @@TIMEOUT) 
			result[:response] = res.as_json 
			result[:status] = true 
		rescue => ex 
		end 
		result 
	end 
	def self.make_get_request(url: "" , payload: {} ) 
		execute_request(url: url, method: :get, payload: payload) 
	end 
	def self.make_post_request(url: "" , payload: {} ) 
		execute_request(url: url, method: :post, payload: payload) 
	end 
	def self.make_put_request(url: "" , payload: {} ) 
		execute_request(url: url, method: :put, payload: payload) 
	end 
	def self.make_delete_request(url: "" , payload: {} ) 
		execute_request( url: url,method: :delete, payload: payload) 
	end 
end