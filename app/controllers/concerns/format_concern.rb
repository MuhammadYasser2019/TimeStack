module FormatConcern
    include ActiveSupport::Concern

		def format_response_json(response)
			{
				'message': response[:message], 
				'result': response[:result],	
				'status': response[:status]
			}
    end
end