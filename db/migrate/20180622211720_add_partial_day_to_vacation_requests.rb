class AddPartialDayToVacationRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :vacation_requests, :partial_day, :string
  end
end
