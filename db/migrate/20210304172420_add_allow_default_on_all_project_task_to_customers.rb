class AddAllowDefaultOnAllProjectTaskToCustomers < ActiveRecord::Migration[5.2]
	def change
    add_column :customers, :allow_default_on_all_project_tasks, :boolean , :default => false
  	end

end