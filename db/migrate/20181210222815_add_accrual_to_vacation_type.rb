class AddAccrualToVacationType < ActiveRecord::Migration[5.2]
  def change
    add_column :vacation_types, :accrual, :boolean
  end
end
