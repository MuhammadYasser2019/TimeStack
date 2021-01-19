class CreateEmploymentTypesVacationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :employment_types_vacation_types do |t|
      t.integer    :employment_type_id
      t.integer    :vacation_type_id
      
      t.timestamps
    end

    Customer.all.each do |c|
    	c.vacation_types.each do |v|
    		c.employment_types.each do |e|
    			EmploymentTypesVacationType.create(employment_type_id: e.id, vacation_type_id: v.id)
    		end
    	end
    end
  end
end
