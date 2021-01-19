class Shift < ApplicationRecord
  has_many :project_shifts
  has_many :projects, :through => :project_shifts
  belongs_to :customer

  validate :end_date_is_after_start_date


  def end_date_is_after_start_date
    if start_time && end_time && regular_hours
      real_end_time = (start_time.to_datetime + regular_hours.hours).strftime("%l:%M %p")
      if real_end_time[0] == ' '
        real_end_time = real_end_time[1..-1]
      end
      if end_time.to_time < start_time.to_time && real_end_time != end_time
        errors.add(:end_time, "End Date cannot be before the Start Date.")
      end
    end
  end
end
