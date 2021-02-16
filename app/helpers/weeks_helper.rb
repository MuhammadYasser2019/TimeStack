module WeeksHelper
  def find_day(date_str)
    logger.debug "weeks_helper - find_day - param is #{date_str}"
    
    return date_str
  end
  def find_status(week)
    if week.nil?
      return "NEW"
    end
    stat =  Status.find(week.status_id).status
    @time_entries = TimeEntry.where(week_id: week.id).order(:date_of_activity)
    @hours_sum = 0
    @time_entries.each do |t|
      if !t.hours.nil?
        @hours_sum += t.hours
      end
    end
    if stat.nil?
      return "NEW"
    elsif stat == "EDIT"
      return @hours_sum.round(2)
    else
      return stat
    end
  end
  
  def total_hours(week)
    @time_entries = TimeEntry.where(week_id: week.id).order(:date_of_activity)
    @hours_sum = 0
    @time_entries.each do |t|
      if !t.hours.nil?
        @hours_sum += t.hours
      end
    end
    @hours_sum.round(1)
  end 

  def current_week_available(current_user)
    #logger.debug "weeks_helper - current_week_available - See if current user #{current_user.email}, has time entered for this week."
    current_week = Week.where(user_id: current_user, start_date: Date.today.beginning_of_week.strftime('%Y-%m-%d'))
    return current_week
  end
  def get_project_id(project_id)
    if project_id.blank? 
      return nil
    else
      return project_id
    end
  end
  
  def user_represents_projects(current_user)
    if Project.where(user_id: current_user).count == 0
      return false
    else
      return true
    end  
  end
  def user_represents_customers(current_user)
    if Customer.where(user_id: current_user).count == 0
      return false
    else
      return true
    end  
  end

  def user_have_adhoc_permission(current_user)
    if Project.where("adhoc_pm_id=? and adhoc_start_date <= ? and adhoc_end_date >=?", current_user.id, Time.now.to_s(:db), Time.now.to_s(:db) ).count > 0
      return true
    else
      return false
    end
  end

  def check_for_vacation(date, user_id)
    user_vacation_requests = VacationRequest.where("status = ? and user_id = ? and DATE(?) BETWEEN vacation_start_date and vacation_end_date", "Approved", user_id, date)
    return user_vacation_requests.present?
  end
end
