module ShiftsHelper
  def shift_name_and_hours(name, start_time, end_time)
    combined_strings = name + ': ' + start_time + ' - ' + end_time
    return combined_strings
  end
end