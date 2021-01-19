class AddTimeSheetToWeeks < ActiveRecord::Migration[5.2]
  def change
    add_column :weeks, :time_sheet, :string
  end
end
