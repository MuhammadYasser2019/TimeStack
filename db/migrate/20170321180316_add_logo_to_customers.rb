class AddLogoToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :logo, :string
  end
end
