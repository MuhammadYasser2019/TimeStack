class UsersController < ApplicationController 
  load_and_authorize_resource 
  # acts_as_token_authentication_handler_for User
  
  skip_before_action :authenticate_user!, only: :get_user_projects

  def self.unread
      where(:read => false)
  end
 
#Choose Approved Timesheet to Reset
  def reset 
    logger.debug("YOU ARE WATCHING: #{params.inspect}")
    @weeks = Week.where("status_id =? ", 3)
    @users = User.where(:customer_id => params[:customer_id])
    logger.debug("The current users are #{@users.inspect}")
  end 

   def default_week
    default_user = User.find(params[:user_email])
    @show_week = Week.where("status_id = ? and user_id = ?", 3, params[:user_email])
    logger.debug("The default user ID is #{params[:user_email]}") 
    respond_to do |format|
      format.js
    end 
  end 

  #finds the week with a users email, & Week start date/APPROVED status
  def approved_week
    default_user = User.find_by_id(params[:email])
    @approved_week = Week.where("user_id = ? and status_id =? and id = ?", params[:email],3,params[:start_date])
    @time_entry = TimeEntry.where(:week_id => @approved_week)
    logger.debug("TimeEntry ID #{@time_entry.inspect}")
    logger.debug("USER ID #{params[:email]}")
    logger.debug "Week ID #{params[:start_date]}"

    # this logic will show what VR are associated the selected approved weeks
    sd = @approved_week[0].start_date
    ed = @approved_week[0].end_date
    vrt = VacationRequest.where(vacation_start_date: sd..ed)
    logger.debug("These are the VR in this Week. #{vrt.inspect}")
      #Have a pop up that shows the associated vacation
   end 

  def user_account
    @user = current_user
  end

  
  def show
    @user = User.find(params[:id])
  end
  
  def admin
    @users = User.where("parent_user_id IS null").all
    @holidays = Holiday.where(global: true)
    @customers = Customer.all
    @invited_users = User.where("invited_by_id = ?", current_user.id)
    @all_report_logos = ReportLogo.all
    @users_with_logo= User.where("parent_user_id IS ? && report_logo IS NOT ? ", nil, nil)
    @features = Feature.all  
    @announcements = Announcement.all

  end

  def get_user_projects
    user_projects = current_user.projects.pluck(:name)
    render json: format_response_json(
      {
        message: 'User projects retrieved!',
        status: true,
        result: user_projects
      }
  )
  end
  
  def new
    @user = User.find(params[:id])
  end

  
  def create
    logger.debug "PARAMS: #{params[:users]}"
    logger.debug "id is #{params[:id]}"
    if params[:id] == nil
      params[:user].permit!.to_h.each do |p|
        logger.debug "p is #{p}"
        User.find(p[0]).update(p[1].deep_symbolize_keys())
      end
    else
      @user = User.find(params[:id])
      @user.update_attributes(user_params)
    end
    redirect_to admin_path
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def index
    @users = User.where("parent_user_id IS null").all
  end
  
  def update
    logger.debug "PARAMS: #{params.inspect}"
    if params[:id] == nil
      params.each do |p|
        logger.debug "P is #{p}"
      end
    else
      @user = User.find(params[:id])
      @user.update_attributes(user_params)
    end
    redirect_to edit_user_path(@user)
  end
  
  def proxies
    @user = User.find(params[:id])
    logger.debug "@user #{@user.inspect}"
    @proxies = Project.where(proxy: @user.id)
    logger.debug "@project #{@proxies.inspect}"
  end
  
  def proxy_users
    @user = User.find(params[:id])
    @proxy = Project.find(params[:proxy_id])
    @proxy_users = @proxy.users
  end

  def enter_timesheets
    @project_id = params[:proxy_id]
    @p = Project.find(@project_id)
    @users = @p.users
    @user_array = @users.pluck(:id)
    @dates_array = @p.find_dates_to_print(params[:proj_report_start_date], params[:proj_report_end_date], params["current_week"], params["current_month"])
  end

  def show_timesheet_dates  
    @project_id = params[:proxy_id]
    @p = Project.find(@project_id)
    @users = @p.users
    @user_array = @users.pluck(:id)
    @dates_array = @p.find_dates_to_print(params[:proj_report_start_date], params[:proj_report_end_date], params["current_week"], params["current_month"])
    
  end

  def add_proxy_row
    @project_id = params[:proxy_id]
    @p = Project.find(@project_id)
    @dates_array = @p.find_dates_to_print(params[:proj_report_start_date], params[:proj_report_end_date], params["current_week"], params["current_month"])
    @count = params[:count].to_i + 1
    @consultant = User.find params[:user_id]
    respond_to do |format|
      format.js
    end

  end

  def fill_timesheet
    @project_id = params[:proxy_id]
    @p = Project.find(@project_id)
    @users = @p.users
    @dates_array = @p.find_dates_to_print(params[:proj_report_start_date], params[:proj_report_end_date], params["current_week"], params["current_month"])
    @users.each do |u|

      week_array = []
      (0..5).each do |count|
        @dates_array.each do |d|
          if params["task_id_#{u.id}_#{count}"].present?
            week = Week.where("start_date=? && user_id=?", d.to_date.beginning_of_week.strftime('%Y-%m-%d'),u.id).first
            if week.blank?
              week = Week.new
              week.start_date = d.to_date.beginning_of_week.strftime('%Y-%m-%d')
              week.end_date = d.to_date.end_of_week.strftime('%Y-%m-%d') 
              week.user_id = u.id
              week.status_id = Status.find_by_status("EDIT").id
              week.proxy_user_id = current_user.id
              week.save!
            end
            if week.status_id ==1 || week.status_id ==5 
              week.status_id = Status.find_by_status("EDIT").id
              if params["time_entry_#{u.id}_#{count}_#{d}"].present?
                te = TimeEntry.find (params["time_entry_#{u.id}_#{count}_#{d}"])
                te.hours = params["hours_#{u.id}_#{count}_#{d}"]
                te.task_id = params["task_id_#{u.id}_#{count}"]
                te.save
              else
                TimeEntry.where("user_id=? && date_of_activity=? && task_id is null", u.id, d.to_date.to_s ).delete_all
                new_day = TimeEntry.new
                new_day.date_of_activity = d.to_date.to_s
                new_day.project_id = @p.id
                new_day.task_id = params["task_id_#{u.id}_#{count}"]
                new_day.hours = params["hours_#{u.id}_#{count}_#{d}"]
                new_day.updated_by = current_user.id
                new_day.user_id = week.user_id
                new_day.status_id = 5
            
                week.time_entries.push(new_day)
              end
              week.save
              vacation(week)
            end 
          end
        end
      end
    end
    redirect_to show_project_reports_path(id: @project_id, proj_report_start_date: params[:proj_report_start_date], proj_report_end_date: params[:proj_report_end_date])
  end

  def vacation(week)
    @user_vacation_requests = VacationRequest.where("status = ? and vacation_start_date >= ? and user_id = ?", "Approved", week.start_date, current_user.id)
    logger.debug("@@@@@@@@@@@@user_vacation_requests: #{@user_vacation_requests.inspect}")
    week.time_entries.each do |wtime|
      @user_vacation_requests.each do |v|
        if wtime.date_of_activity >= v.vacation_start_date && wtime.date_of_activity <= v.vacation_end_date 
          if v.vacation_type_id.present?
            wtime.vacation_type_id =  v.vacation_type_id
            wtime.activity_log = v.comment 
            wtime.hours = nil
            wtime.save
          end
        end
      end
    end
  end
  
  def invite_customer
    @user = User.invite!(email: params[:email], invitation_start_date: params[:invite_start_date], invited_by_id: params[:invited_by_id])
    @user.update(invited_by_id: params[:invited_by_id], cm: true, customer_id: params[:customer_id] )
    Customer.find(params[:customer_id]).update(user_id: @user.id)
    redirect_to admin_path
  end
  

  def show_user_reports
    
    if params[:commit] == "Download Zip"
      zip_ids = params[:zip_ids]
      if zip_ids.present?
        @uploaded_time_sheets = []
        zip_ids.each do |zip_id|
          @uploaded_file = UploadTimesheet.find zip_id
          @uploaded_time_sheets << @uploaded_file
        end
       @filename = "Timesheet_#{Time.now.to_date.strftime('%Y%m%d')}.zip"
        present_time =  Time.now.to_i
        folder_path = "#{Rails.root}/public/downloads_#{present_time}/"
        zipfile_name = "#{Rails.root}/public/archive_#{present_time}.zip"

        FileUtils.remove_dir(folder_path) if Dir.exist?(folder_path)
        FileUtils.remove_entry(zipfile_name) if File.exist?(zipfile_name)
        Dir.mkdir("#{Rails.root}/public/downloads_#{present_time}")
        @uploaded_time_sheets.each do |attachment|
          open(folder_path + "#{attachment.time_sheet_identifier}", 'wb') do |file|
            file << open("#{Rails.root}/public/" +"#{attachment.time_sheet.url}").read
          end
        end
        input_filenames = Dir.entries(folder_path).select {|f| !File.directory? f}
        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          input_filenames.each do |attachment|
            zipfile.add(attachment,File.join(folder_path,attachment))
          end
        end
        FileUtils.remove_dir(folder_path) if Dir.exist?(folder_path)
        send_file("#{Rails.root}/public/archive_#{present_time}.zip", :type => 'application/zip', :filename => @filename)
      end
    else
    logger.debug("IN THE SHOW USER REPORT*******: #{params.inspect}")
    @print_report = "false"
    logger.debug("******CHECKING hidden_print_report: #{params[:hidden_print_report].inspect}")
    @print_report = params[:hidden_print_report] if !params[:hidden_print_report].nil?
    if params[:id].blank?
      @user = current_user
    else
      @user = User.find(params[:id])
    end


    logger.debug("What are the dates, #{params[:proj_report_start_date].inspect}")
    if params[:proj_report_start_date].blank?
      logger.debug("Are you in here or there$%^&$%^&$%&$%^&$%&$%^^&$%^&$%^&$&$%^&$%^&$%^&$%^&$%^&")
      params[:proj_report_start_date] = Date.today.strftime("%Y-%m-01")
      params[:proj_report_end_date] = Date.today.strftime("%Y-%m-%d")
    end 
    
    user_id = @user.id
    @users = User.all
    @user_projects = @user.projects
    @current_user_id = current_user.id
    @project = Project.find_by_id params[:selected_project_id]
    time_period = params[:proj_report_start_date]..params[:proj_report_end_date]
    if !params[:project].blank?
      logger.debug "getting here?"
      @time_entries = TimeEntry.where(project_id: params[:project],user_id: @user.id, date_of_activity: time_period).order(:date_of_activity)
    else
      @time_entries = TimeEntry.where(user_id: @user.id,date_of_activity: time_period).order(:date_of_activity)
    end
    
    
    @dates_array = @user.find_dates_to_print(params[:proj_report_start_date], params[:proj_report_end_date])
    logger.debug "HELLO THERE: #{@dates_array}"
    @daily_totals = Array.new
    full_date_array = @user.full_date_array(params[:proj_report_start_date], params[:proj_report_end_date])
    full_date_array.each do |d|
      hours_today = TimeEntry.where(user_id: @user.id, date_of_activity: d).sum(:hours)
      logger.debug "HOURS TODAY: #{hours_today}"
      @daily_totals << hours_today
    end
    @days_of_week  = @user.days_of_week(params[:proj_report_start_date], params[:proj_report_end_date])
    @weekend_days = Array.new
    count = 0
    @days_of_week.each do |d|
      count += 1
      if d == "Sun" || d == "Sat"
        @weekend_days << count
      end
    end
    @consultant_hash = @user.user_times(params[:proj_report_start_date], params[:proj_report_end_date], @user)
    if params[:proj_report_start_date]
      start_split = params[:proj_report_start_date].split("-")
      @start_date = start_split[1] + "/" + start_split[2] + "/" + start_split[0]
    end
    if params[:proj_report_end_date]
      end_split = params[:proj_report_end_date].split("-")
      @end_date = end_split[1] + "/" +end_split[2] + "/" + end_split[0]
    end
    @hours_sum = 0
    @time_entries.each do |t|
      if !t.hours.nil?
        @hours_sum += t.hours
      end
    end
   
    # @week = Week.where("start_date >=? and end_date <=? and user_id=?", params["proj_report_start_date"], params["proj_report_end_date"], @user.id)
    @week ,@weekIds = @user.find_week_id(params[:proj_report_start_date], params[:proj_report_end_date], @user)
    if !params[:project].blank?
    @expenses = ExpenseRecord.where(week_id: @weekIds , project_id: params[:project])
    else
    @expenses = ExpenseRecord.where(week_id: @weekIds)
    end
    @expenseattachment=ExpenseAttachment.where(expense_record_id: @expenses.ids)    
    @amount_sum = 0
    @expenses.each do |t|
      if !t.amount.nil?
        @amount_sum += t.amount
      end
    end
    @available_csv = 0;
    @week.each do|w|
      w.upload_timesheets.each do |t|
        if t.time_sheet.present?
          @available_csv += 1
        end
      end
    end
    logger.debug("THE WEEKS IN USER ARE : #{@week}")
    split_url = request.original_url.split("/")
    period_url = split_url[4].split("?")
    logger.debug "PERIOD DEBUG #{period_url}"
    logger.debug "SPLIT: #{split_url[0]} and #{split_url[2]} and #{split_url[3]} and #{split_url[4]}"
    if period_url[1].nil?
      @url = split_url[0] + "//" + split_url[2] + "/" + split_url[3] + "/" + period_url[0] + ".xlsx"
    else
      @url = split_url[0] + "//" + split_url[2] + "/" + split_url[3] + "/" + period_url[0] + ".xlsx" + "?" + period_url[1]
    end
    @customer = Customer.where(id: current_user.customer_id).first
    @shift = @customer.shifts.where(name: 'Regular', default: true).first
    logger.debug "URLLLLLLL: #{@url}"

     respond_to do |format|
      format.xlsx
      format.html{}

    end
  end
end


  def show_user_weekly_reports
    
    if params[:commit] == "Download Zip"
      zip_ids = params[:zip_ids]
      if zip_ids.present?
        @uploaded_time_sheets = []
        zip_ids.each do |zip_id|
          @uploaded_file = UploadTimesheet.find zip_id
          @uploaded_time_sheets << @uploaded_file
        end
       @filename = "Timesheet_#{Time.now.to_date.strftime('%Y%m%d')}.zip"
        present_time =  Time.now.to_i
        folder_path = "#{Rails.root}/public/downloads_#{present_time}/"
        zipfile_name = "#{Rails.root}/public/archive_#{present_time}.zip"

        FileUtils.remove_dir(folder_path) if Dir.exist?(folder_path)
        FileUtils.remove_entry(zipfile_name) if File.exist?(zipfile_name)
        Dir.mkdir("#{Rails.root}/public/downloads_#{present_time}")
        @uploaded_time_sheets.each do |attachment|
          open(folder_path + "#{attachment.time_sheet_identifier}", 'wb') do |file|
            file << open("#{Rails.root}/public/" +"#{attachment.time_sheet.url}").read
          end
        end
        input_filenames = Dir.entries(folder_path).select {|f| !File.directory? f}
        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          input_filenames.each do |attachment|
            zipfile.add(attachment,File.join(folder_path,attachment))
          end
        end
        FileUtils.remove_dir(folder_path) if Dir.exist?(folder_path)
        send_file("#{Rails.root}/public/archive_#{present_time}.zip", :type => 'application/zip', :filename => @filename)
        end
    else
      if params[:id].blank?
        @user = current_user
      else
        @user = User.find(params[:id])
      end

      if params["proj_report_end_date"].present?
        params[:month] = params["proj_report_end_date"].to_date.month
      end
      if params[:month].blank?
        logger.debug("Are you in here or there$%^&$%^&$%&$%^&$%&$%^^&$%^&$%^&$&$%^&$%^&$%^&$%^&$%^&")
        proj_report_start_date = Time.now.beginning_of_month
        if Time.now.end_of_month ==0
          proj_report_end_date = Time.now.end_of_month + 6.days
        else
          proj_report_end_date = Time.now.end_of_month
        end
      else
        mon = Time.now.month-params[:month].to_i
        proj_report_start_date = (Time.now.beginning_of_month - mon.month)
        if (Time.now.end_of_month - mon.month).wday ==0
          proj_report_end_date = (Time.now.end_of_month - mon.month) + 6.days
        else
        if Time.now.month == 2 
          proj_report_end_date = ((Time.now + 1.month).end_of_month - mon.month)
        else
          proj_report_end_date = (Time.now.end_of_month - mon.month)
        end
      end
    end 
    user_id = @user.id
    @users = User.all
    @project = Project.find_by_id params[:selected_project_id]
    user_project = @user.projects
    @user_projects = user_project

    @current_user_id = current_user.id
    time_period = proj_report_start_date..proj_report_end_date

    time_entries = TimeEntry.where(user_id: @user.id,date_of_activity: time_period).order(:date_of_activity)
    week_array = time_entries.collect(&:week_id).uniq
    @time_hash = {}
    
    week_array.each do |w|
      @time_hash[w] = {}
      week = Week.find_by_id w
      if week
        if params[:project_id].present?
          time_entry = week.time_entries.where(project_id: params[:project_id],date_of_activity: time_period).order(:date_of_activity)
        else
          time_entry = week.time_entries.where(project_id: @user_projects.collect(&:id), date_of_activity: time_period).order(:date_of_activity)
        end  
        time_entry.each do |t|  
          @time_hash[w][t.project_id] ||= {}
          @time_hash[w][t.project_id][t.task_id] ||= Array.new(7,0.0) if (t.date_of_activity.wday != 0 && t.project_id.present?) || (t.date_of_activity.wday != 7 && t.project_id.present?)
          time = t.hours.present? ? t.hours : 0.0 
          @time_hash[w][t.project_id][t.task_id][t.date_of_activity.wday] += time if @time_hash[w][t.project_id][t.task_id].present?
        end
      end
    end
    
    @week ,@weekIds = @user.find_week_id(proj_report_start_date, proj_report_end_date, @user)
    @available_csv = 0;
    @week.each do|w|
      w.upload_timesheets.each do |t|
        if t.time_sheet.present?
          @available_csv += 1
        end
      end
    end
    
    respond_to do |format|
      format.xlsx
      format.html{}

      end
    end
  end

  def user_profile
    @user = current_user
    
    @default_project = @user.default_project
    @default_task = @user.default_task
    @project_tasks = Task.where(project_id: @default_project)
    logger.debug("the project tasks are: #{@project_tasks.inspect}")

    @customer_id = current_user.customer_id
    @vacation_types = VacationType.where("customer_id=? and paid=?", @customer_id, true)         
    
    s_year = Date.today.strftime('%Y').to_i
    start_date = s_year.to_s + "-01-01"

    @sss = start_date
    end_date = Date.today
    @eee = end_date
    emp_type = EmploymentType.where(id: @user.employment_type).last
    @customer_types = emp_type.vacation_types 
    customer = Customer.find(@customer_id)
    shift = customer.shifts.where(name: 'Regular', default: true).first
    full_work_day = shift ? shift.regular_hours : 8
    logger.debug("full work day #{full_work_day}")

    @user_hash = {}
                
    vt_hash = {}
    @hours_array = []
    @customer_types.each do |ct|
      ###Shared Logic
      request_year = (end_date.to_date.strftime('%Y').to_f) - (start_date.to_date.strftime('%Y').to_f)
      request_months = (end_date.to_date.year * 12 + end_date.to_date.month) - (start_date.to_date.year * 12 + start_date.to_date.month)
      months_to_date = end_date.to_date.strftime('%m').to_f
          ###
      days_to_hours = ct.vacation_bank.to_f * full_work_day.to_f
      hours_per_month = (days_to_hours/12).to_f

      logger.debug("request_months#{request_months} x hours_per_month#{hours_per_month} ")
      logger.debug(" What is ct #{ct.inspect}")

      ###Calc the hours Avaliable in that time frame
      logger.debug("Checking the vacation bank #{ct.vacation_bank}")
      if ct.vacation_bank?
        if ct.accrual == false  && ct.rollover == false 
          logger.debug(" Non Accural and No Rollover")
          hours_avaliable = ct.vacation_bank.to_f * full_work_day.to_f
          logger.debug("hours_avaliable is #{hours_avaliable}")

        elsif ct.accrual == false && ct.rollover == true
          logger.debug(" Non Accural and Rollover")
          year_hours_avaliable = ct.vacation_bank.to_f * full_work_day.to_f
          request_year = request_year + 1
          hours_avaliable = year_hours_avaliable.to_f * request_year
          logger.debug("hours_avaliable is #{hours_avaliable}")

        elsif ct.accrual == true && ct.rollover == false 
          logger.debug("Accural and No Rollover")
          hours_avaliable = (hours_per_month.to_f * months_to_date.to_f).to_f
          logger.debug("hours_avaliable is #{hours_avaliable}")

        elsif ct.accrual == true && ct.rollover == true
          logger.debug("Accural and Rollover")
          hours_avaliable = (hours_per_month * request_months).to_f
          if hours_avaliable == 0
            hours_avaliable = hours_per_month.to_f
          end 
          logger.debug("hours_avaliable is #{hours_avaliable}")
        else 
          logger.debug("Accural and or rolloer is nil ")
          hours_avaliable = 0
        end
        @hours_array.push(hours_avaliable.round(2))
      else
        @hours_array.push("NA")
      end 

      @uvrF = VacationRequest.where("user_id = ? and vacation_type_id = ?", @user, ct)
      d_range = (start_date.to_date .. end_date.to_date)
      @uvr=[]
      logger.debug("what is uvr #{@uvr}")
      @uvrF.each do |ww|
        in_range = d_range.cover?(ww.vacation_start_date)
        if in_range == true
            @uvr.push(ww)
        end 
      end 
      #######
      currentuser = @user.email 
      if @uvr.length < 1 
          vt_hash[ct.id] = hours_avaliable
      else 
        total_hours_used = @uvr.pluck(:hours_used) 

        sum_of_hours = []
        total_hours_used.each do |x|
          x = x.to_f
          sum_of_hours.push(x)
        end
        sum_of_hours = sum_of_hours.sum 
      end

      #######
      if sum_of_hours == nil
        sum_of_hours = hours_avaliable.to_f
      else 
        sum_of_hours = hours_avaliable.to_f - sum_of_hours.to_f
      end
      vt_hash[ct.id] = sum_of_hours.round(2)
      sum_of_hours =[]
      logger.debug("What is the VT_HASH #{vt_hash}")
      @user_hash[currentuser] = vt_hash
     ##logger.debug("hash... #{@user_hash}")
    end 
  end

  def user_notification
    @user = current_user
    @notifications = @user.user_notifications.order(created_at: :desc)  
    logger.debug "The NOTIFICATIONS ARE: #{@notifications}"
    @notification_ids = @user.user_notifications.pluck(:id)
    logger.debug "THE NOTIF IDS ARE: #{@notification_ids}"
    
  end

  def manage_profiles
    @customer = Customer.where(id: current_user.customer_id).first
    @employment_type = EmploymentType.where(customer_id: @customer.id)
    @invited_users = User.where("parent_user_id = ?", current_user.id)
    @projects = current_user.projects

  end

  def assign_project
    if params[:project_id].present?
      project = Project.find(params[:project_id])
      user = User.find(params[:user_id]) 
      #remove sub user from project while assigning different project
      ProjectsUser.where(user_id: user.id).destroy_all if user.projects.present?
      #add sub user to project
      project.users.push(user) if !project.users.include?(user)
      project.save
    end
    respond_to do |format|
      format.js
    end
  end

  def login_user
    if params[:id].present?
      user = User.find params[:id]
      sign_out(current_user)
      sign_in(:user, user)
      if current_user.cm?
        return redirect_to customers_path
      elsif current_user.pm?
        return redirect_to projects_path
      else
        redirect_to weeks_path
      end      
    end
  end

  def invite_sub_users
    logger.debug "INVITED BY #{params[:invited_by_id]}"
    project = Project.find(params[:project_id])
    project_id = params[:project_id]
    existing_user = User.find_by(email: params[:email])
    if existing_user.present?
      flash[:alert]= "User already exists"
      return redirect_to manage_profiles_path 
    else
      @user = User.invite!(email: params[:email], :invitation_start_date => params[:invite_start_date],:employment_type => params[:employment_type], invited_by_id: params[:invited_by_id].to_i, default_project: project_id)
      @user.update(invited_by_id: params[:invited_by_id], customer_id: project.customer_id, parent_user_id: current_user.id)
      pu = ProjectsUser.new
    
      user = User.find(@user.id)
    
      if project.users.include?(user)
        
      else
        project.users.push(user)
      end
      project.save
    end

    redirect_to manage_profiles_path
  end

  def user_notification_date
    logger.debug(params[:created_at])
    @user = current_user
    logger.debug("USER IS : #{@user.inspect}")
    week_id = params[:week_id]
   # created_at = params[:created_at].to_date
    #week_id = Week.where("end_date = :date and user_id = :user_id", {:date => created_at - 1.day, user_id: @user.id}).pluck(:id)

    #for getting user notifications 
    @user_notification_id = UserNotification.find(params[:notification_id])
    logger.debug "THE user notification id : #{@user_notification_id}"
    
    if @user_notification_id.user_id == current_user.id
      @user_notification_id.update_attributes(:seen => Time.now)
    end

    #id = week_ids.first
     #Week.where(end_date: wek).pluck(:id)
    
    logger.debug("WEEK ID : #{week_id}")
    respond_to do |format|
      format.html { redirect_to "/weeks/#{week_id}/edit" }
    end
  end

  def get_notification
    @notification = UserNotification.where(id: params[:notification_id]).first
    @notification.update_attributes(visited: true, seen: true) 
  end

  def set_default_project
    logger.debug("THE PARAMETERS ARE: #{params.inspect}")
    default_project_id = params[:default_project_id]
    default_task_id = params[:default_task_id]
    user = current_user
    user.default_project = default_project_id
    user.default_task = default_task_id
    user.save

    respond_to do |format|
        format.html { redirect_to "/", notice: 'Defaul project set' }
    end
  end

  def get_announcement
        @announcements_data = Announcement.all
    end

  def assign_report_logo_to_user
    logger.debug("the PARAMETERS for assigning RL: #{params.inspect}")
    user = User.find(params[:user])
    report_logo_id = params[:report_logo]
    user.report_logo = report_logo_id
    user.save
    logger.debug("The use email is : #{user.email}")

    respond_to do |format|
        format.html { redirect_to "/admin", notice: 'Logo assigned to User' }
    end
  end


  def add_multiple_user_recommendation
    @recommended_users = params[:user_ids].split(',').map(&:to_i)
      @recommended_users.each do|user|
        u_recommendation  = UserRecommendation.new
        u_recommendation.recommendation = params[:recommendation]
        u_recommendation.user_id  = user
        u_recommendation.submitted_by = current_user.id
        u_recommendation.project_id = params[:project_id]
        u_recommendation.save
      end
    respond_to do |format|
      format.js
      #format.html { redirect_to "/projects", notice: 'Recommendation is added successfully.' }
    end  
  end

  def add_multiple_user_disciplinary
    @disciplinary_users = params[:disc_user_ids].split(',').map(&:to_i)
      @disciplinary_users.each do|user|
        u_disc  = UserDisciplinary.new
        u_disc.disciplinary = params[:disciplinary]
        u_disc.user_id  = user
        u_disc.submitted_by = current_user.id
        u_disc.project_id = params[:project_id]
        u_disc.save
      end
    respond_to do |format|
      format.js
      #format.html { redirect_to "/projects", notice: 'Recommendation is added successfully.' }
    end  
  end


  def add_multiple_user_inventory

      @inventory_users = params[:inv_user_ids].split(/[" "]+/).map(&:to_i) if params[:inv_user_ids].present?
      @project = Project.find_by_id params[:project_id]
      if @inventory_users.present?
        @inventory_users.each do|user|
        u_env_and_equip                  = UserInventoryAndEquipment.new
        u_env_and_equip.equipment_number = params["equipment_number_#{user}"]
        u_env_and_equip.equipment_name   = params["equipment_name_#{user}"]
        u_env_and_equip.user_id          = user
        u_env_and_equip.project_id       = params[:project_id]
        u_env_and_equip.issued_by        = current_user.id
        u_env_and_equip.issued_date      = params["issued_date_#{user}"]
        u_env_and_equip.save
        end
      end
      
      respond_to do |format|
        format.js
      end
      
  end

  def set_inventory_submitted_date
    u_env_and_equip = UserInventoryAndEquipment.find params[:inventory_id]
    @project = Project.find_by_id u_env_and_equip.project_id
    u_env_and_equip.submitted_date = params[:inventory_dates]
    u_env_and_equip.save
      respond_to do |format|
          format.js
      end
  end

  def accept_terms_and_condition
    if params[:accept_terms_and_condition].present? && params[:user_id].present?
        user = User.find params[:user_id]
        user.terms_and_condition = params[:accept_terms_and_condition]
        user.save
      end
      redirect_to root_path
  end

  private
  
    def user_params
      params.require(:user).permit(:id, :first_name, :last_name, :email, :password, :password_confirmation, :user, :cm, :pm, :admin, :proxy, :invited_by_id,:user_ids,:project_id,:recommendation,:accept_terms_and_condition)
    end
end