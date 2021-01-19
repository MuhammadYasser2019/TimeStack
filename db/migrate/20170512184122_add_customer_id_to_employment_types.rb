class AddCustomerIdToEmploymentTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :employment_types, :customer_id, :integer
  end
end
