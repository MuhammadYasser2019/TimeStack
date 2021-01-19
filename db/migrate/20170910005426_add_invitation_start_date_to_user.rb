class AddInvitationStartDateToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :invitation_start_date, :datetime
  end
end
