class ProjectShift < ApplicationRecord
  belongs_to :shift
  belongs_to :project
  has_many :time_entries
  has_many :projects_users, -> { where current_shift: true }
  has_many :users, through: :projects_users




  def shift_name
  	self.shift.name + ': ' + self.shift.start_time + ' - ' + self.shift.end_time
  end

  def start_time
  	Date.today.beginning_of_year
  end

  def end_time
  	Date.today.end_of_month
  end

end
