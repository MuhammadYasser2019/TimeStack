class ArchivedWeek < ApplicationRecord
	belongs_to :week
	has_many :archived_time_entry
end
