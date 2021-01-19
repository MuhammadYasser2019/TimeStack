class HolidayException < ApplicationRecord
  serialize :holiday_ids, Array
  belongs_to :user
  belongs_to :project
end
