class CreateExpenseAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :expense_attachments do |t|
      t.string :attachment
      t.integer :expense_record_id

      t.timestamps
    end
  end
end
