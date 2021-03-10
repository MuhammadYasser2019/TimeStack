namespace :invite_to_project_using_file do 
	desc "invite to project using csv file"
	task :invite_user => :environment do
		require 'csv'
		 file_details = []
          hash = Hash.new
        
		CSV.open("#{Rails.root}/public/invited_user.csv", "wb",headers: true) do |csv|	
            csv << ['email','token']
	    	CSV.foreach("#{Rails.root}/public/WFP-ChronStack-Users-Filled-out.csv", headers: true ) do |row|
			    begin   	
		        	hash = convert_row_to_hash(row)
		            @customer=Customer.find 13
		            @employment_type=EmploymentType.where(customer_id: @customer.id,name: hash["Employment Types"]).first
		            if @employment_type.present?
			            if(hash["User Role"]=="Regular User")
			            	@user = User.invite!(email: hash["User Email Address"], :invitation_start_date => DateTime.now.strftime("%Y-%m-%d"), :employment_type => @employment_type.id, invited_by_id: @customer.user_id )
			            elsif(hash["User Role"]=="Project Manager")
			          		@user = User.invite!(email: hash["User Email Address"], :invitation_start_date => DateTime.now.strftime("%Y-%m-%d"), :employment_type => @employment_type.id, invited_by_id: @customer.user_id, pm: 1)
		    			end
		    		end
		    		url = Rails.application.routes.url_helpers.accept_user_invitation_url(:invitation_token => @user.raw_invitation_token, :host=> 'https://chronstack.com')
		          	csv << [@user.email ,url]
		          	puts "Email sent for #{@user.id}"
		            @user.update(invited_by_id: @customer.user_id, customer_id: @customer.id)  	    
	    		rescue => ex
	    			puts "Failed for #{hash["User Email Address"]}"
	    		csv << [@user.email ,ex]
    		end
		  end
		end
		ApprovalMailer.mail_for_invite_csv("CSV File of Invited User").deliver_now
	end
end

def convert_row_to_hash(row)
	return row.to_hash.each {|k, v|}
end