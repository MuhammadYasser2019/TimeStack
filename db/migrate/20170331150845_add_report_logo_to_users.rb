class AddReportLogoToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :report_logo, :integer
  end
end
