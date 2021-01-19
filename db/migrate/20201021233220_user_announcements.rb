class UserAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :user_announcements do |t|
      t.integer  :announcement_id
      t.integer  :user_id
    end
  end
end
