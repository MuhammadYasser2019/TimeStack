class AddVacationTypeInTimeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :vacation_type_id, :integer

    TimeEntry.reset_column_information
  	TimeEntry.all.each do |t|
  	  if t.user_id.present?	
		u = User.find t.user_id
		if u.customer_id.present?
		  c = Customer.find u.customer_id
		  if t.sick?
		  	v = c.vacation_types.where("vacation_title =?", "Sick").first
		  	t.vacation_type_id = v.id
		  elsif t.personal_day?
		  	v = c.vacation_types.where("vacation_title =?", "Personal").first
		  	t.vacation_type_id = v.id
		  end
		  t.save!
		end
	  end
  	end
  end
end
