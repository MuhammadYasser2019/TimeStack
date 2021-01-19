class CreateUserInventoryAndEquipments < ActiveRecord::Migration[5.2]
  def change
    create_table :user_inventory_and_equipments do |t|
      t.integer :issued_by
      t.string :equipment_name
      t.string :equipment_number
      t.datetime :issued_date
      t.datetime :submitted_date
      t.integer :project_id
      t.references :user

      t.timestamps
    end
  end
end
