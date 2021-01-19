class AddCurrentShiftInShiftChangeRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :shift_change_requests, :current_shift_name, :string
    
  end
end
