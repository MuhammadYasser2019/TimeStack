class UserVacationTable < ApplicationRecord
		belongs_to :user
		has_many :vacation_types
end
