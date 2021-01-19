class AddDefaultCommentToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :default_comment, :text
  end
end
