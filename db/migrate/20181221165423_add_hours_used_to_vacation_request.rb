class AddHoursUsedToVacationRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :vacation_requests, :hours_used, :decimal, precision: 5, scale: 2
  end
end