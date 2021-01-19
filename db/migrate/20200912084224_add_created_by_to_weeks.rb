class AddCreatedByToWeeks < ActiveRecord::Migration[5.2]
  def change
    add_column :weeks, :created_by, :int
  end
end
