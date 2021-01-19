class AddVacationTypeInVacationRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :vacation_requests, :vacation_type_id, :integer

    TimeEntry.reset_column_information
  	VacationRequest.all.each do |t|
  	  if t.customer_id.present?
		c = Customer.find t.customer_id
		if t.sick?
		  v = c.vacation_types.where("vacation_title =?", "Sick").first
		  t.vacation_type_id = v.id
		elsif t.personal?
		  v = c.vacation_types.where("vacation_title =?", "Personal").first
		  t.vacation_type_id = v.id
		end
		t.save!
	  end
  	end
  end
end
