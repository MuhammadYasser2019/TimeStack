module ProjectsHelper
  def consultant_name(fname, lname, email)
    consultant_name = email
    if fname.nil? || lname.nil?
  
    else
      consultant_name = "#{fname} #{lname}"
    end
    return consultant_name
  end

  def task_remaining_hour(task_id)
  	
  	if task_id.present?  		      
  		used_time=TimeEntry.where("task_id=? and status_id in(?,?)",task_id,2,3).sum(:hours)
  		total_time = Task.find(task_id).estimated_time
	  	if total_time.present?
	  		avaliable_time =  total_time - used_time
	  	else
	  		return avaliable_time = nil
	  	end
  	else
  		avaliable_time=nil
  	end
  	return avaliable_time 		
  	
  end
  def estimated_task_time_exceed(project_id,week_id) 
    if project_id.present?
      task=Task.where(:project_id => project_id)
      time_exceed = false
      task.each  do |t|
        task_hours=TimeEntry.where(:task_id => t.id,:week_id => week_id).sum(:hours)
        esmt_hours=Task.find(t.id).estimated_time
        if esmt_hours.present? && task_hours > esmt_hours 
          time_exceed = true
          break;
        else
          next
        end
       end 
       if time_exceed
        return true
       else
        return false
       end 
    else
      return false
    end
  end
  def jira_project_shift(customer_id)
     shifts = Shift.where(customer_id: customer_id)
     shift_array = []
      shifts.each do |shift|
          name_and_shift_period = shift.name + ': ' + shift.start_time + ' - ' + shift.end_time
          shift_array << [name_and_shift_period, shift.id]
      end
      return shift_array
  end
end
