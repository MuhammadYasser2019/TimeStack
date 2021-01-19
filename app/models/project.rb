class Project < ApplicationRecord
  require 'rubygems'
  require 'jira-ruby'


  belongs_to :customer
  has_many :tasks
  has_many :time_entries
  has_many :projects_users
  has_many :users, :through => :projects_users do
    def active_users
        where("projects_users.sepration_date IS NULL AND current_shift is true")
    end

    def inactive_users
      where("projects_users.sepration_date IS NOT NULL AND current_shift is true")
    end
  end

  has_many :holiday_exceptions
  has_many :project_shifts
  has_many :shifts, :through => :project_shifts
  has_many :shift_change_requests
  accepts_nested_attributes_for :tasks, allow_destroy: true



  
  def self.task_value(task_attributes, previous_codes)
    logger.debug("Checking the tasks in projects model")
    task_value = Array.new
    task_attributes.permit!.to_h.each do |t|
      logger.debug("#############333 #{t[1]["code"].inspect}")
      code = t[1]["code"]
      task_value << code

    end
    logger.debug("########task_value #{task_value.inspect}")
    previous_codes |= task_value
    logger.debug "PREVIOUS CODES: #{previous_codes.inspect}"
    return previous_codes
  end

  def self.find_jira_projects(customer_id, project_id=nil)
    current_user = User.find customer_id
    customer = Customer.find current_user.customer_id
    @configuration = customer.external_configurations.where(system_type: 'jira').first
    if @configuration.present?
	    options = {
	      :username     => @configuration.jira_email,
	      :password     => @configuration.password,
	      :site         => @configuration.url+':443/',
	      :context_path => '',
	      :auth_type    => :basic
	    }
      begin
	      client = JIRA::Client.new(options)
      
        
        if project_id.present? 
          project = client.Project.find project_id
        else
  	      project = client.Project.all
        end
      rescue
        return "error"
      end
		else
			return nil
		end
  end
  
  def self.previous_codes(project)
    codes = Array.new
    project.tasks.each do |t|
      codes << t.code
    end
    return codes
  end


  def deliver(users,subject,body)
    if users.present?
      users.each do|u|
        user = User.find u
        email = user.email
        UserNotifyMailer.mail_with_subject(email,subject,body).deliver_now
      end
    end
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
  
  def build_consultant_hash(project_id, dates_array, start_date, end_date, users, current_week=nil, current_month=nil, billable)
    hash_report_data = Hash.new
    consultant_ids = users
    if current_month == "current_month"
      start_date = Time.now.beginning_of_month.to_date.to_s
    elsif current_month == "last_month"
      start_date = (Time.now.beginning_of_month-1.month).to_date.to_s
    elsif start_date.nil? || current_month == "current_week"
      start_date = Time.now.beginning_of_week.to_date.to_s
    else
      start_date = start_date
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
    consultant_ids.flatten.each do |c|
      time_entries = TimeEntry.where(user_id: c, project_id: project_id, date_of_activity: start_date..end_date).order(:date_of_activity)
      logger.debug "consultant is #{c}"
      employee_time_hash = Hash.new
      total_hours = 0
      daily_hours = 0
      time_entries.each do |t|
        #to get billable hours
        task_ids = t.task_id
        task = Task.find(task_ids) if task_ids.present?
        #logger.debug "The Task billable are : #{task.billable}"
        logger.debug "Billable is : #{billable.class}"
        task_value = (task.present? && task.billable) ? "true" : "false"
        logger.debug "THE taks VALUE ARE : #{task_value.class}"
        #logger.debug "COMPARISION IS : #{task_value == billable}"
        if task_value == billable
          #logger.debug "TASK BILLABLE inside ARE: #{task.billable}"
          if !employee_time_hash[t.date_of_activity.strftime('%m/%d')].blank?
            if employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours].blank?
              daily_hours = t.hours if !t.hours.blank?
              daily_hours = 0 if t.hours.blank?
            else
              daily_hours = employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours] + t.hours if !t.hours.blank?
              daily_hours = employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours] if t.hours.blank?
            end
          else 
            daily_hours = !t.hours.blank? ? t.hours : 0
          end
        total_hours = total_hours + t.hours if !t.hours.blank?
        employee_time_hash[t.date_of_activity.strftime('%m/%d')] = { id: t.id, hours: daily_hours, activity_log: t.activity_log }
       end
    end

      u = User.find(c)
      hash_report_data[c] = { daily_hash: employee_time_hash, total_hours: total_hours }
    end
    logger.debug "build_consultant_hash - hash_report_data is #{hash_report_data.inspect}"
    return hash_report_data
  end



  def build_inventory_hash(start_date,end_date,users,project_id, submitted_type=nil,current_month=nil)
      @results = []

      users_ids = users
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
        
      users_ids.flatten.each do|u|
        c = User.find(u)
        if submitted_type == "submitted" 
          Rails.logger.info " first"
           inventory_records = UserInventoryAndEquipment.where(user_id: u, project_id: project_id, created_at: start_date..end_date).where.not(submitted_date: nil)
            inventory_records.each do|inv|
              row                        = Hash.new
              row["Consultant Name"]     = c.email
              row["Equipment Name"]      = inv.equipment_name
              row["Equipment Number"]    = inv.equipment_number
              row["Issue Date"]          = inv.issued_date
              row["Submitted Date"]      = inv.submitted_date

              @results << row
            end
        elsif submitted_type == "not_submitted"
          Rails.logger.info " Second"
           inventory_records = UserInventoryAndEquipment.where(user_id: u, project_id: project_id, submitted_date: nil,created_at: start_date..end_date)
           inventory_records.each do|inv|
              row                        = Hash.new
              row["Consultant Name"]     = c.email
              row["Equipment Name"]      = inv.equipment_name
              row["Equipment Number"]    = inv.equipment_number
              row["Issue Date"]          = inv.issued_date
              row["Submitted Date"]      = inv.submitted_date

              @results << row
            end
        elsif submitted_type == "" &&  start_date && end_date 
        Rails.logger.info "Third" 
          inventory_records = UserInventoryAndEquipment.where(user_id: u, project_id: project_id, created_at: start_date..end_date)
          inventory_records.each do|inv|
              row                        = Hash.new
              row["Consultant Name"]     = c.email
              row["Equipment Name"]      = inv.equipment_name
              row["Equipment Number"]    = inv.equipment_number
              row["Issue Date"]          = inv.issued_date
              row["Submitted Date"]      = inv.submitted_date

              @results << row
            end
        else
           inventory_records = UserInventoryAndEquipment.where(user_id: u, project_id: project_id)
           Rails.logger.info "Fourth"
           inventory_records.each do|inv|
              row                        = Hash.new
              row["Consultant Name"]     = c.email
              row["Equipment Name"]      = inv.equipment_name
              row["Equipment Number"]    = inv.equipment_number
              row["Issue Date"]          = inv.issued_date
              row["Submitted Date"]      = inv.submitted_date

              @results << row
            end
        end    
      end

       @results
  end
  
  def self.convert_date_format(date_str)
    logger.debug "DATE_STR #{date_str}"
    if date_str.nil?
      date_str = Time.now.strftime('%m-%d-%Y')
    end
    date_arr = date_str.split("-") 
    return date_arr[2] + "/" + date_arr[0] + "/" + date_arr[1]
  end
end
