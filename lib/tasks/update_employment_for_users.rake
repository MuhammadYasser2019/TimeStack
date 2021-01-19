namespace :update_employment_for_users do
	desc "update employemt id for users"
	task :update => :environment do
		User.all.each do |u|
			if u.customer_id.present?
				customer = Customer.find u.customer_id
				if customer.employment_types.blank?
					etype = EmploymentType.create!(customer_id: customer.id, name: "Contractor") 
					u.employment_type = etype.id
				else	
					u.employment_type = customer.employment_types.first.id
				end
				u.save
			end
		end
	end
	
end