class CreateSharedEmployees < ActiveRecord::Migration[5.2]
	def change
		create_table :shared_employees do |t|
			t.integer :user_id
			t.integer :customer_id
			t.boolean :permanent, default: false

			t.timestamps null: false
		end
	end
end