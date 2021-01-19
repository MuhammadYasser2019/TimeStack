class AddThemeToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :theme, :string
  end
end
