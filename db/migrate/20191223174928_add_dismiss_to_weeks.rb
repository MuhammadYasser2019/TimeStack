class AddDismissToWeeks < ActiveRecord::Migration[5.2]
  def change
    add_column :weeks, :dismiss, :boolean, default: false
  end
end
