class CreateHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :holidays do |t|
      t.string :name
      t.boolean :global

      t.timestamps
    end
  end
end
