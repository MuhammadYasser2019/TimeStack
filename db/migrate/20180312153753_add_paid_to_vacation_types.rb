class AddPaidToVacationTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :vacation_types, :paid, :boolean
  end
end
