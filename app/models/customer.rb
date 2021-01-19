class Customer < ApplicationRecord 
  has_many :projects
  has_and_belongs_to_many :holidays, join_table: :customers_holidays
  accepts_nested_attributes_for :projects, allow_destroy: true, reject_if: proc { |projects| projects[:name].blank? }
  has_many :vacation_requests
  has_many :employment_types
  mount_uploader :logo, LogoUploader
  has_many :vacation_types
  has_many :external_configurations
  has_one :default_report
  has_many :shifts
  has_many :user


  validates_numericality_of :zipcode

  EXTERNAL_SYSTEMS= {
    'Jira' => 'jira',
    'Redmine' => 'redmine'
  }
  

  def build_consultant_hash(customer_id, dates_array, start_date, end_date, users, projects, current_week=nil, current_month=nil, billable)
    logger.debug "Billable are :#{billable}"
    hash_report_data = Hash.new
    consultant_ids = users
    customer = Customer.find(customer_id)

    if current_month == "current_month"
      start_day = Time.now.beginning_of_month.to_date.to_s
    elsif current_month == "last_month"
      start_day = (Time.now.beginning_of_month-1.month).to_date.to_s
    elsif start_date.nil? || current_month == "current_week"
      start_day = Time.now.beginning_of_week.to_date.to_s
    else
      start_day = start_date
    end


    if current_month == "current_month"
      end_date = Time.now.end_of_month.to_date.to_s
    elsif current_month == "last_month"
      end_date = (Time.now - 1.month).end_of_month.to_date.to_s
    elsif end_date.nil? || current_month == "current_week"
      end_date = Time.now.end_of_week.to_date.to_s
    else
      end_date = end_date
    end

    logger.debug "consultant_ids: #{consultant_ids}"
    if (projects.is_a? Integer) || (projects.is_a? String) || (projects.is_a? Array)
      project_list = Project.find projects
    else
      project_list = projects
    end

    consultant_ids.flatten.each do |c|
     total_hours = 0
     project_list.each do |p|
      time_entries = TimeEntry.where(user_id: c, project_id: p.id, date_of_activity: start_day..end_date).order(:date_of_activity)
      logger.debug "consultant is #{c}"
      employee_time_hash = Hash.new
      daily_hours = 0
      count = 1
      time_entries.each do |t|
        logger.debug "COUNT THIS: #{count}"
        count += 1
        #to get billable hours
        task_ids = t.task_id
        task = Task.find(task_ids) if task_ids.present?
        #logger.debug "The Task billable are : #{task.billable}"
        logger.debug "Billable is : #{billable.class}"
        task_value = (task.present? && task.billable) ? "true" : "false"
        logger.debug "THE taks VALUE ARE : #{task_value.class}"
        #logger.debug "COMPARISION IS : #{task_value == billable}" 
        if billable.blank? || task_value == billable 
          #logger.debug "TASK BILLABLE inside ARE: #{task.billable}"
          if !employee_time_hash[t.date_of_activity.strftime('%m/%d')].blank?
            logger.debug "EMPLOYEE TIME HASH: #{employee_time_hash[t.date_of_activity.strftime('%m/%d')]}"
            if employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours].blank?
              daily_hours = t.hours if !t.hours.blank?
              daily_hours = 0 if t.hours.blank?
            else
              logger.debug "DAILY HOURS 1: #{daily_hours}"
              daily_hours = employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours] + t.hours if !t.hours.blank?
              daily_hours = employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours] if t.hours.blank?
              logger.debug "DAILY HOURS 2: #{daily_hours}"
            end
          else
            daily_hours = !t.hours.blank? ? t.hours : 0
            logger.debug "DAILY HOURS 3: #{daily_hours}"
          end
        
          total_hours = total_hours + t.hours if !t.hours.blank?
          employee_time_hash[t.date_of_activity.strftime('%m/%d')] = { id: t.id, hours: daily_hours, activity_log: t.activity_log }
        end
        
      end
      logger.debug "POST LOOP EMPLOYEE HASH: #{employee_time_hash.inspect}"
      if hash_report_data[c].blank?
        hash_report_data[c] = { daily_hash: employee_time_hash, total_hours: total_hours } if hash_report_data[c].nil?
        logger.debug "DAILY HASH: #{hash_report_data[c][:daily_hash]}"
      else
        logger.debug "UUUHHHHHHHH"
        hash_report_data[c][:daily_hash].each do |d|
          unless employee_time_hash[d[0]].blank?
            logger.debug "WHAT IS D #{d} AND WHAT IS D[0] #{d[0]}"
            logger.debug "EMPLOYEE TIME HASH D[0]: #{employee_time_hash[d[0]]}"
            employee_time_hash[d[0]][:hours] += d[1][:hours]
          else
            employee_time_hash[d[0]] = d[1]
          end
        end
        hash_report_data[c] = { daily_hash: employee_time_hash, total_hours: total_hours } if !hash_report_data[c].nil?
      end
         logger.debug "HASH REPORT_DATA: #{hash_report_data}"
     end
    end
    logger.debug "build_consultant_hash - hash_report_data is #{hash_report_data.inspect}"
    return hash_report_data
  end

  def build_project_report(projects, shifts, start_date, end_date, current_month)

    if current_month == "current_month"
      start_day = Time.now.beginning_of_month.to_date.to_s
    elsif current_month == "last_month"
      start_day = (Time.now.beginning_of_month-1.month).to_date.to_s
    elsif start_date.nil? || current_month == "current_week"
      start_day = Time.now.beginning_of_week.to_date.to_s
    else
      start_day = start_date
    end

    if current_month == "current_month"
      end_date = Time.now.end_of_month.to_date.to_s
    elsif current_month == "last_month"
      end_date = (Time.now - 1.month).end_of_month.to_date.to_s
    elsif end_date.nil? || current_month == "current_week"
      end_date = Time.now.end_of_week.to_date.to_s
    else
      end_date = end_date
    end
    project_hash = {}

    projects.each do |p|
      project_hash[p.id] ||= {}
      p.tasks.each do |t|
        project_hash[p.id][t.id] ||= {}
        shifts.each do |s|
          submitted_time = 0.0
          approved_time = 0.0
          s.project_shifts.where(project_id: p.id).each do |ps|
            project_hash[p.id][t.id][ps.id] ||= []
            submitted_time += TimeEntry.where(project_shift_id: ps.id, task_id: t.id, project_id: p.id, date_of_activity: start_day..end_date, status_id: 2).order(:date_of_activity).sum(:hours)
            approved_time += TimeEntry.where(project_shift_id: ps.id, task_id: t.id, project_id: p.id, date_of_activity: start_day..end_date, status_id: 3).order(:date_of_activity).sum(:hours)
            project_hash[p.id][t.id][ps.id] << approved_time
            project_hash[p.id][t.id][ps.id] << submitted_time
          end
         
        end
      end
    end

    return project_hash

  end

  def find_dates_to_print(proj_report_start_date = nil, proj_report_end_date = nil, current_week = nil, current_month = nil) 
    if current_month == "current_month"
      start_day = Time.now.beginning_of_month
    elsif current_month == "last_month"
      start_day = Time.now.beginning_of_month-1.month
    elsif proj_report_start_date.nil? || current_month == "current_week"
      start_day = Time.now.beginning_of_week
    else
      start_day = Date.parse(proj_report_start_date)
    end

    if current_month == "current_month"
      last_day = Time.now.end_of_month
    elsif current_month == "last_month"
      last_day = (Time.now - 1.month).end_of_month
    elsif proj_report_end_date.nil? || current_month == "current_week"
      last_day = start_day.end_of_week
    else
      last_day = Date.parse(proj_report_end_date).end_of_day
    end
    dates_array = []
    this_day = start_day
    while this_day < last_day
      dates_array << this_day.strftime('%m/%d')
      this_day = this_day.tomorrow

    end
    logger.debug "DATE ARRAAAAAAAAAAAAAAAAY: #{dates_array}"
    return dates_array
  end

  def find_week_id(start_date, end_date,user_array)
    week_array = []
    user_array.each do |u|
      t = TimeEntry.where(user_id: u, date_of_activity: start_date..end_date)
      logger.debug("THE T ARE : #{t} and the user is #{u}")
      t.each do |tw|
        week_array << tw.week_id
      end
    end
    week_with_attachment_array = []
    week_array.uniq.each do |w|
      week_with_attachment_array << Week.find(w) if UploadTimesheet.find_by_week_id(w).present?
    end
    return week_with_attachment_array

  end
  ##
    def self.holiday_weekend_count(user,start_date,end_date)
  ##########Now Holidays 
      logger.debug("Current User id is #{user.customer_id}")
            customer_holidays = CustomersHoliday.where(:customer_id => user.customer_id)
            holiday_array = []
              customer_holidays.each do |x|
                h_date = Holiday.find(x.holiday_id)
                holiday_array.push(h_date.date.to_date)
              end
            logger.debug(" HOLIDAY DATES #{holiday_array}")
  ##########CURRENT SOLUTION TO CHECK IF IT IS A HOLIDAY
            start_year_array = []
            end_year_array = []
            holiday_array.each do |correct|
              requested_start_year  = start_date.to_s.split('-')[0]
              year_start = requested_start_year.to_s + '-' + correct.to_s.split('-')[1] + '-' + correct.to_s.split('-')[2]
              start_year_array.push(year_start.to_date)

              requested_end_year = end_date.to_s.split('-')[0] 
              year_end = requested_end_year.to_s + '-' + correct.to_s.split('-')[1] + '-' + correct.to_s.split('-')[2]
              end_year_array.push(year_end.to_date)
            end 
              logger.debug("Start year Array is #{start_year_array}")
              logger.debug("End year array is #{end_year_array}")
  #########Dates Requested on weekend ?
            a_range = (start_date.to_date .. end_date.to_date)
            weekend_counter = 0
            a_range.each do |date|
              if date.on_weekend? == true
                weekend_counter = weekend_counter + 1
              end 
            end
  ########## Prevents the same array from being checked
            if start_year_array == end_year_array
              logger.debug("both arrays are not needed")
            else
              start_year_array.each do |ww|
                b = a_range.cover?(ww.to_date)
                if b == true
                  weekend_counter = weekend_counter + 1
                end 
                logger.debug(" #{ww.to_date} is a holiday #{b}")
              end 
            end 
            end_year_array.each do |ww|
              b = a_range.cover?(ww.to_date)
              if b == true
                weekend_counter = weekend_counter + 1
              end 
              logger.debug(" #{ww.to_date} is a holiday #{b}")
            end 
            logger.debug("Wekend Count + holiday #{weekend_counter}")
            ####
           ### Holiday Check (use if holiday.dates updates automatically)
           #logger.debug("Wekend Count #{weekend_counter}")
           #holiday_array.each do |ww|
           #  b = a_range.cover?(ww.to_date)
           #  if b == true
           #    weekend_counter = weekend_counter + 1
           #  end 
           #  logger.debug(" #{ww.to_date} is a holiday #{b}")
           #end 
        ###
        return weekend_counter
  end 

  def self.is_vacation_allowed(uvt, vacation_type, user,full_work_day)
      @vacation_type = vacation_type

      hours_over_month = (full_work_day.to_f/12).to_f
      hour_rate = @vacation_type.vacation_bank.to_f * hours_over_month
      
    if @vacation_type.vacation_bank == 0 || @vacation_type.vacation_bank == nil
        logger.debug("This VacationType.vacation_bank is 0 or NIL")
        hours_allowed = "BANANA"
        return hours_allowed
    else
        @user = user
        
        if @user.invitation_start_date?
          year = (Date.today.strftime('%Y').to_f) - (@user.invitation_start_date.strftime('%Y').to_f)
            logger.debug("years at job #{year}")
          months = (Date.today.to_date.year * 12 + (Date.today.to_date.month) - (@user.invitation_start_date.to_date.year * 12 + @user.invitation_start_date.to_date.month))
           logger.debug("REAL months at job #{months}")
        else 
          logger.debug("user has no invitation_start_date, using created at.")
          year = (Date.today.strftime('%Y').to_f) - (@user.created_at.strftime('%Y').to_f)
            logger.debug("years at job #{year}")
          months = (Date.today.to_date.year * 12 + (Date.today.to_date.month) - (@user.created_at.to_date.year * 12 + @user.created_at.to_date.month))
           logger.debug("REAL months at job #{months}")
        end

        if @vacation_type.vacation_bank == nil 
          vb = 0
        else 
          vb  = @vacation_type.vacation_bank * full_work_day #converts days to hours
        end
        ###Calculate Total Hours
                    total_used = []
                    uvt.each do |x|
                      if x.hours_used != nil
                        total_used.push(x.hours_used)
                      else 
                          total_used.push(0)
                      end 
                    end
                    total_hours_used = total_used.inject :+

        ### Accrual Rollover/NewYear Logic
                    if @vacation_type.rollover == true && @vacation_type.accrual == true
                      logger.debug("rollover is true and accural is true")
                    months_at_job = months
                      logger.debug("months at job #{months_at_job}")
                      
                    elsif @vacation_type.rollover == false && @vacation_type.accrual == true 
                              #Start accrual over at 0. ie) start 3-2018, its 3-2019.. they have 3 months at job for vacation matters
                              months_at_job = Date.today.strftime('%m').to_f
                    elsif @vacation_type.rollover == true && @vacation_type.accrual == false
                              year = year + 1
                              nvb = vb * year 
                    elsif @vacation_type.rollover == false && @vacation_type.accrual == false
                              nvb = vb
                    else 
                        logger.debug("Vacation Type is nil in either/both rollover/accrual")
                    end

        ####Hour Allowed Logic 
                    if (@vacation_type.accrual == true && uvt.length > 0 )
                        logger.debug(" A = TRUE && UVT != 0")
                        current_hours_allowed = hour_rate * months_at_job #This changes***
                        logger.debug("Accrual current_hours_allowed #{current_hours_allowed}")
                        hours_allowed = current_hours_allowed - total_hours_used 

                    elsif (@vacation_type.accrual == true && uvt.length <= 0)
                        logger.debug(" A = TRUE && UVT is 0")
                        hours_allowed = hour_rate * months_at_job  

                    elsif (@vacation_type.accrual == false && uvt.length > 0)
                          logger.debug(" A == FALSE && UVT != 0")                    
                          hours_allowed = nvb.to_f - total_hours_used

                    elsif (@vacation_type.accrual == false && uvt.length <= 0)
                        logger.debug(" A = FALSE && UVT = 0")
                        hours_allowed = nvb.to_f
                    else
                        logger.debug("$$$$$$$$ Vacation Type.accrual is NIL #{@vacation_type.accrual}")
                    end #End Hours Allowed
            return hours_allowed
        end #End If for vacation_type.length
  end

  def build_inventory_hash(start_date,end_date,users,projects, submitted_type=nil,current_month=nil)
    all_inventories_hash = {}
    if current_month == "current_month"
      start_date = Time.now.beginning_of_month.to_date.to_s
    elsif current_month == "last_month"
      start_date = (Time.now.beginning_of_month-1.month).to_date.to_s
    else
      start_date = start_date
    end

    if current_month == "current_month"
      end_date = Time.now.end_of_month.to_date.to_s
    elsif current_month == "last_month"
      end_date = (Time.now - 1.month).end_of_month.to_date.to_s
    else
      end_date = end_date
    end

    if (projects.is_a? Integer) || (projects.is_a? String) || (projects.is_a? Array)
      project_list = Project.find projects
    else
      project_list = projects
    end

    customer_row = {}

    project_list.each do |p|
      all_inventories_hash = p.build_inventory_hash(start_date,end_date,users, p.id ,submitted_type,current_month)  
    end
    all_inventories_hash
  end

end
