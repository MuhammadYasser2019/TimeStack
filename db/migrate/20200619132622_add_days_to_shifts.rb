class AddDaysToShifts < ActiveRecord::Migration[5.2]
  def change
    add_column :shifts, :mon, :boolean, :default => false
    add_column :shifts, :tue, :boolean, :default => false
    add_column :shifts, :wed, :boolean, :default => false
    add_column :shifts, :thu, :boolean, :default => false
    add_column :shifts, :fri, :boolean, :default => false
    add_column :shifts, :sat, :boolean, :default => false
    add_column :shifts, :sun, :boolean, :default => false
  end
end
