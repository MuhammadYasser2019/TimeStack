class AddDateToHolidays < ActiveRecord::Migration[5.2]
  def change
    add_column :holidays, :date, :datetime
  end
end
