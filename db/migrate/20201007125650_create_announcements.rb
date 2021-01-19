class CreateAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :announcements do |t|
      t.string  :announcement_type
      t.text  :announcement_text
      t.date    :start_date
      t.date    :end_date
      t.boolean :active
      t.boolean :seen
      t.timestamps null: false
    end
  end
end
