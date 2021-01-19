class CreateExpenseRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :expense_records do |t|
      t.string :expense_type
      t.text :description
      t.date :date
      t.integer :amount
      t.string :attachment
      t.integer :project_id
      t.belongs_to :week

      t.timestamps 
    end
  end
end