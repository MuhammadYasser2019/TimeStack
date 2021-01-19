class UserWeekStatus < ApplicationRecord
  belongs_to :week
  
  def self.first_for_user(current_user_id, week_id)
    UserWeekStatus.where(user_id: current_user_id, week_id: week_id).first
  end
end
