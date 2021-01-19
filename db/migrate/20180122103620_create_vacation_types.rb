class CreateVacationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :vacation_types do |t|
      t.integer 	:customer_id
      t.string    :employment_type
      t.string   	:vacation_title
      t.integer		:max_days
      t.boolean		:rollover
      t.boolean		:active

      t.timestamps
    end

    Customer.all.each do |c|
      VacationType.create!(vacation_title: "Personal", customer_id: c.id, active: true)
      VacationType.create!(vacation_title: "Sick", customer_id: c.id, active: true)
    end
  end
end
