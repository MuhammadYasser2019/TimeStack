class AddVacationStartDateAndVacationEndDateAndSickAndPersonalAndStatusToVacationRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :vacation_requests, :vacation_start_date, :datetime
    add_column :vacation_requests, :vacation_end_date, :datetime
    add_column :vacation_requests, :sick, :integer,:limit => 1
    add_column :vacation_requests, :personal, :integer,:limit => 1
    add_column :vacation_requests, :status, :string
  end
end
