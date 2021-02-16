class WeeksController < ApplicationController
  before_action :set_week, only: [:show, :edit, :update, :destroy]
  before_action :redirect_to_root, only: [:show]


  load_and_authorize_resource
  # GET /weeks
  # GET /weeks.json
  def index
    logger.debug" PARAMTER ARE #{params} and CURRENT USER IS #{current_user}"
    @user = current_user
    @shift_supervisor_project_shift = @user.project_shifts.where(shift_supervisor_id: @user.id).last
    @terms_modal_show = current_user.terms_and_condition
    @announcement = Announcement.where("active = true").last
    if current_user.cm? || current_user.proxy_cm?
      return redirect_to customers_path
    elsif current_user.pm?
      return redirect_to projects_path
    end

    @default_project = @user.default_project
    @default_task = @user.default_task
    @project_tasks = Task.where(project_id: @default_project)
    logger.debug("the project tasks are: #{@project_tasks.inspect}")
    @projects =  Project.all
    #@weeks = Week.includes("user_week_statuses").where("user_week_statuses.user_id =  ?", current_user.id)

    @weeks  = Week.where("user_id = ?", current_user.id).order(start_date: :desc).limit(10)
    @projects.each do |p|
      if p.adhoc_pm_id.present? && p.adhoc_end_date.to_s(:db) < Time.now.to_s(:db)
        p.adhoc_pm_id = nil
        p.adhoc_start_date = nil
        p.adhoc_end_date = nil
        p.save
      end
    end
  end 

  # GET /weeks/1
  # GET /weeks/1.json
  def show

    #@projects =  Project.all
    #@week = Week.includes("user_week_statuses").find(params[:id])
    #status_ids = [1,2] 
    #@statuses = Status.find(status_ids)
    #@tasks = Task.all
    @projects =  Project.all
    @week = Week.includes("user_week_statuses").find(params[:id])
    status_ids = [1,2] 
    @statuses = Status.find(status_ids)
    @tasks = Task.all
  end

  def change_status
    logger.debug" PARAMTER ARE #{params}"
    #find for which user
    @time_entry = TimeEntry.where(:week_id => params[:week_id])
     @time_entry.each do |t|
      aw = ArchivedTimeEntry.new 
      aw.date_of_activity = t.date_of_activity
      aw.hours  = t.hours
      aw.activity_log = t.activity_log
      aw.task_id = t.task_id
      aw.week_id = t.week_id
      aw.user_id = t.user_id
      aw.created_at = t.created_at
      aw.updated_at = t.updated_at
      aw.project_id = t.project_id
      aw.sick = t.sick
      aw.personal_day = t.personal_day
      aw.updated_by = t.updated_by
      aw.status_id = t.status_id
      aw.approved_by = t.approved_by
      aw.approved_date = t.approved_date
      aw.time_in = t.time_in
      aw.time_out = t.time_out
      aw.vacation_type_id = t.vacation_type_id
      aw.save
    end 
    #if archivedweek with start_date, end_date & user_id already present?
    #do not create
    w = Week.find(params[:week_id])
    #if ArchivedWeek.where("start_date =? AND user_id =? AND week_id = ?", w.start_date,w.user_id,w.id).blank?
      cw = ArchivedWeek.new
      cw.start_date = w.start_date           
      cw.end_date =w.end_date         
      cw.created_at =w.created_at                            
      cw.updated_at= w.updated_at                      
      cw.user_id = w.user_id
      cw.status_id =w.status_id    
      cw.approved_date = w.approved_date        
      cw.approved_by = w.approved_by      
      cw.comments = w.comments         
      cw.time_sheet = w.time_sheet       
      cw.proxy_user_id = w.proxy_user_id        
      cw.proxy_updated_date = w.proxy_updated_date 
      cw.week_id = w.id
      cw.reset_reason = params[:reason_for_reset]
      cw.reset_by = current_user.id
      cw.reset_date = Time.now 
      cw.save
    logger.debug("THIS IS THE WEEK BEFORE#{@week.inspect}")
   # end 
    w.status_id = 5
    w.save 
    logger.debug("THIS IS THE WEEK CHANGED #{@week.inspect}")
    respond_to do |format|
      format.js
    end 
  end 

  # GET /weeks/new
  def new

    #@projects =  Project.joins(:projects_users).where("projects_users.user_id=? AND inactive=?", current_user.id, false )
    if params[:start_date].present?
      start_date  = params[:start_date].to_date.strftime('%Y-%m-%d')
      end_date = params[:end_date].to_date.strftime('%Y-%m-%d')
      @week = Week.new
      @week.start_date = start_date
      @week.end_date = end_date
      @week.user_id = current_user.id
      @week.status_id = Status.find_by_status("NEW").id
      @week.proxy_user_id = current_user.id
      @week.save!
    else
      @week = Week.new
      @week.start_date = Date.today.beginning_of_week.strftime('%Y-%m-%d')
      @week.end_date = Date.today.end_of_week.strftime('%Y-%m-%d') 
      @week.user_id = params[:user_id].present? ? params[:user_id] : current_user.id
      @week.status_id = Status.find_by_status("NEW").id
      @week.proxy_user_id = current_user.id
      @week.save!
    end

    if current_user.id == @week.user_id
      @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=?", current_user.id )
    else
      @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=?", @week.user_id )
    end
    logger.debug("these are the projects#{@projects.inspect}")
    if !@projects.first.nil?
      @tasks = Task.where(project_id: @projects.first.id)
    end


    7.times {  @week.time_entries.build( user_id: @week.user_id, status_id: 1 )}
      
    @week.time_entries.each_with_index do |te, i|
      logger.debug "weeks_controller - edit now for each time_entry we need to set the date  and user_id and also set the hours  to 0"
      logger.debug "year: #{@week.start_date.year}, month: #{@week.start_date.month}, day: #{@week.start_date.day}"
      @week.time_entries[i].date_of_activity = Date.new(@week.start_date.year, @week.start_date.month, @week.start_date.day) + i
      @week.time_entries[i].user_id = @week.user_id
    end
    @week.save!

    @week_user = User.find(@week.user_id)
    emp_type = EmploymentType.find current_user.employment_type
    @vacation_types = emp_type.vacation_types.where("customer_id=? && active=?", @week_user.customer_id, true)
    vacation(@week)
    @upload_timesheet = @week.upload_timesheets.build
  end

  def copy_timesheet
    current_week_id = params[:id]
    current_week = Week.find(current_week_id)
    current_week.copy_last_week_timesheet(current_week.user_id)
    hours_array =[]
    current_week.time_entries.each do |w|
      if !w.hours.nil?
        hours_array.push("true")
      end 
    end
    hours_array
    if !hours_array.empty?

     current_week.status_id = 5 
     current_week.save
    end

    redirect_to root_path
  end

  def clear_timesheet
    logger.debug("WEEKS CONTROLLER --------------")
    current_week_id = params[:id]
    current_week = Week.find(current_week_id)
    current_week.clear_current_week_timesheet
    current_week.status_id = 1 
    current_week.save

    redirect_to root_path
  end

  # GET /weeks/1/edit
  def edit
    #@week = Week.eager_load(:time_entries).where("weeks.id = ? and time_entries.user_id = ?", params[:id], current_user.id).take
    @week = Week.find(params[:id])
    @user_id = current_user.id
    @week_user = User.find(@week.user_id)    
    logger.debug("WEEK USER IS: #{@week_user.inspect}")
    if @week.status_id == 4
      logger.debug "THE STATUS IS FOOOOOOOOUOUOUOUOUOUOUOUOUOUOUOUOUUOUOUOUOOUOUOUR"
      @time_entries = @week.time_entries.where(status_id: 4)
    elsif @week.status_id == nil || @week.status_id == 1
      @time_entries = @week.time_entries.where(status_id: [nil, 1])
    elsif @week.status_id == 2 || @week.status_id == 3
      @time_entries = @week.time_entries.where(status_id: @week.status_id)
    end
    
    if current_user == @week.user_id
      @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=? && current_shift=?", current_user.id , true)
    else
      @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=? && current_shift=?", @week.user_id, true )
    end
    @week.start_date = Week.find(params[:id]).start_date.strftime('%Y-%m-%d')
    @week.end_date = Week.find(params[:id]).end_date.strftime('%Y-%m-%d')
    status_ids = [1,2]
    @statuses = Status.find(status_ids)
    emp_type = EmploymentType.find current_user.employment_type
    @vacation_types = emp_type.vacation_types.where("customer_id=? && active=?", @week_user.customer_id, true)
    @tasks = Task.where(project_id: 1) if @tasks.blank?
    @expenses = ExpenseRecord.where(week_id: @week.id)
    @expenseattachment=ExpenseAttachment.where(expense_record_id: @expenses.ids)
    @week.upload_timesheets.build if @week.upload_timesheets.blank?
    vacation(@week)
    # vr.where("status = ? && vacation_start_date >= ?", "Approved", @week.start_date)
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
            wtime.save
          end
        end
      end
    end
  end

  def time_entry_week_hours          
     @hours = params[:hours]

     @week = Week.find(params[:week_id])     
     
     @week_user = User.find(@week.user_id)
     
     @time_entries = TimeEntry.where("user_id= ? and week_id= ?",current_user.id,@week.id)
     if @time_entries.present?
        time_entry_days = @time_entries.count - 2
        @dayhour = (@hours.to_f/time_entry_days).round(1)
      end      
     @time_entries.each do |time_entry|
      if time_entry.date_of_activity.wday == 6
      elsif time_entry.date_of_activity.wday == 0
      else
        time_entry.hours = @dayhour
        time_entry.project_id = current_user.default_project
        time_entry.task_id = current_user.default_task 
        time_entry.status_id = 5
        time_entry.save
      end

     end
      @week.status_id=5
      @week.save
      redirect_to root_path
  end

  def previous_comments
     @wuser = params[:user_id]
     @week_id = params[:week_id]

     @t = TimeEntry.where.not(activity_log: "").where("user_id= ?",params[:user_id]).order(created_at: :desc) .limit(10)
     @t.each do |t|
      logger.debug("PRINT T #{t.inspect}")
     end

     logger.debug("PREVIOUS COMMENTS WEEKS CONTROLLER_________________________ #{@t.inspect}")
     #@time_entries = @week.time_entries.where(activity_log: )
     #@week_user = User.find(@week.user_id)
     #@t = TimeEntry.find(@t.activity_log)

  end



  def add_previous_comments
    #@wuser = User.find(params[:id])
    @week_id = params[:week_id ]
    @time_entry = TimeEntry.find(params[:activity_log])

    respond_to do |format|
      format.js
    end
  end

  # POST /weeks
  # POST /weeks.json
  def create
    @week = Week.new(week_params)
    @week.proxy_user_id = current_user.id
    @week.proxy_updated_date = Time.now
    prev_date_of_activity =""
    if current_user == @week.user_id
      @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=? && current_shift=?", current_user.id , true)
    else
      @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=? && current_shift=?", @week.user_id, true )
    end
    @week_user = User.find(@week.user_id)
    emp_type = EmploymentType.find current_user.employment_type
    @vacation_types = emp_type.vacation_types.where("customer_id=? && active=?", @week_user.customer_id, true)
    week_params["time_entries_attributes"].each do |t|
      # store teh date of activity from previous row
      if !t[1][:date_of_activity].nil?
        prev_date_of_activity = t[1][:date_of_activity]
      else
        new_day = TimeEntry.new
        new_day.date_of_activity = prev_date_of_activity
        new_day.project_id = t[1][:project_id]
        new_day.task_id = t[1][:task_id]
        new_day.hours = t[1][:hours]
        new_day.activity_log = t[1][:activity_log]
        new_day.updated_by = t[1][:updated_by]

        @week.time_entries.push(new_day)
      end
    end

    respond_to do |format|
      if @week.save
        format.html { redirect_to @week, notice: 'Week was successfully created.' }
        format.json { render :show, status: :created, location: @week }
      else
        format.html { render :new }
        format.json { render json: @week.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /weeks/1
  # PATCH/PUT /weeks/1.json
  
  def update

    logger.debug("week params: #{params.inspect}")
    logger.debug("week params: #{week_params["time_entries_attributes"]}")
    week = Week.find(params[:id])
    logger.debug(" WHAT IS THIS #{week.id}")
    test_array = []
    week_user = week.user_id
    logger.debug("THE USER ON THE WEEK IS: #{week_user}")
    prev_date_of_activity =""
    prev_hours = 0      
    overtime = false
    notice_detail =""
    count=0   
    timesheet_activity_list = Hash.new
    error_activity_list = Hash.new
    hashKey=""
    projrct_date=""
    if current_user == @week.user_id
      @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=? && current_shift=?", current_user.id , true)
    else
      @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=? && current_shift=?", @week.user_id, true )
    end
    @week_user = User.find(week.user_id)
    emp_type = EmploymentType.find current_user.employment_type
    @vacation_types = emp_type.vacation_types.where("customer_id=? && active=?", @week_user.customer_id, true)
    week_params["time_entries_attributes"].permit!.to_h.each do |t|
      # store the date of activity from previous row
      overtime=false
  if  t[1][:hours].present?
    if !t[1][:date_of_activity].nil? && t[1][:date_of_activity] != prev_date_of_activity
      prev_hours = 0  
      overtime = false      
    end
    prev_hours  = prev_hours + t[1][:hours].to_i    
    #prev_project = t[1][:project_id]
    project_details = Project.where(id: t[1][:project_id]).last     
    project_user = ProjectsUser.where(project_id: t[1][:project_id] ,user_id: week.user_id).last
    ps =  ProjectShift.where(id: project_user.project_shift_id).last 
    shift_hours = ps.present? ? ps.shift.regular_hours : 8     
    if t[1][:task_id].present?
        #prev_task = t[1][:task_id]
        @tasks_details = Task.where(id: t[1][:task_id]).last        
        if @tasks_details.present? && @tasks_details.overtime.present?
          overtime = @tasks_details.overtime
        end
        
      hashKey =t[1][:date_of_activity].nil? ? prev_date_of_activity+"_"+t[1][:project_id].to_s+"_"+t[1][:task_id].to_s+"_"+overtime.to_s : t[1][:date_of_activity].to_s+"_"+t[1][:project_id].to_s+"_"+t[1][:task_id].to_s+"_"+overtime.to_s
    
    else
      hashKey =t[1][:date_of_activity].nil? ? prev_date_of_activity+"_"+t[1][:project_id].to_s : t[1][:date_of_activity].to_s+"_"+t[1][:project_id].to_s
    end

   if (timesheet_activity_list.has_key?(hashKey))        
        timesheet_activity_list[hashKey] = timesheet_activity_list[hashKey]+t[1][:hours].to_i
    else
     # timesheet_activity_list.key = hashKey
      timesheet_activity_list[hashKey] = t[1][:hours].to_i
    end
    if t[1][:date_of_activity].nil?
      projrct_date = (prev_date_of_activity.to_date).strftime('%Y-%m-%d')
    else
      projrct_date = (t[1][:date_of_activity].to_date).strftime('%Y-%m-%d')
    end
    if timesheet_activity_list[hashKey]>shift_hours && overtime==false && !t[1][:task_id].nil?
          count =count+1
          if (!error_activity_list.has_key?(hashKey+"_"+shift_hours.to_s))        
            error_activity_list[hashKey+"_"+shift_hours.to_s] = count.to_s+" : "+projrct_date+"  Project #{project_details.name} and task #{@tasks_details.description} hours exceed to "+shift_hours.to_s+" hours. \n"
          end
          #notice_detail += count.to_s+" : "+projrct_date+"  Project #{project_details.name} and task #{@tasks_details.description} hours exide to 8 hours. \n"                
    elsif (overtime == true || t[1][:task_id].nil?) && timesheet_activity_list[hashKey]>24      
      count =count+1
      if (!error_activity_list.has_key?(hashKey+"_Task_24"))        
            error_activity_list[hashKey+"_Task_24"] = count.to_s+" : "+projrct_date+"  Project #{project_details.name} hours exceed to 24 hours. \n"  
      end
      #notice_detail += count.to_s+" : "+projrct_date+"  Project #{project_details.name} hours exide to 24 hours. \n"            
    elsif  prev_hours>24
      count =count+1
      if (!error_activity_list.has_key?(hashKey+"_OverALl_24"))        
            error_activity_list[hashKey+"_OverALl_24"] = count.to_s+" : "+projrct_date+"  Over all day hours exceed.\n"
      end
      #notice_detail += count.to_s+" : "+projrct_date+"  Over all day hours exide.\n"
    end  
    
  end

      if !t[1][:date_of_activity].nil?
        logger.debug "DATE OF ACTIVITY IS NOT NIL"
        prev_date_of_activity = t[1][:date_of_activity]
      else        
        if t[1][:date_of_activity].nil? && t[1][:hours].present?
          logger.debug "DATE OF ACTIVITY IS ACTUALLY NIL MAN"
          new_day = TimeEntry.new
          new_day.date_of_activity = prev_date_of_activity
          new_day.project_id = t[1][:project_id]
          new_day.task_id = t[1][:task_id]
          new_day.hours = t[1][:hours]
          new_day.activity_log = t[1][:activity_log]
          new_day.updated_by = t[1][:updated_by]
          new_day.user_id = week_user
          new_day.partial_day = t[1][:partial_day]        
          @week.time_entries.push(new_day)
        end
      end                                   #End if !t[1]
      logger.debug "#{t[0]}"
      if t[1]["project_id"] == "" 
        t[1]["project_id"] = nil
        t[1]["task_id"] = nil

        unless TimeEntry.where(id: t[1]["id"]).empty?
          TimeEntry.find(t[1]["id"]).update(project_id: nil, task_id: nil) 
        end # unless
      end # if t[1] project

      if t[1]["vacation_type_id"].present? && t[1]["hours"].nil? && TimeEntry.where(id: t[1]["id"]).present?
        TimeEntry.find(t[1]["id"]).update(hours: nil, partial_day: "false",project_id: nil, task_id: nil, activity_log: nil)
      end #end if t[1] vacation_type
 
      # if t[0].to_i > 6
      #   logger.debug "t[1][project_id]: #{t[1]['project_id']}"
      #   logger.debug "t[1][task_id]: #{t[1]['task_id']}"
      #   unless TimeEntry.where(id: t[1]["id"]).empty?
      #     TimeEntry.create( week_id: @week.id, project_id: t[1]["project_id"], task_id: t[1]["task_id"], hours: t[1]["hours"], user_id: current_user.id, activity_log: t[1]["activity_log"], date_of_activity: t[1]["date_of_activity"])
      #   end
      # end
      if !t[1]["hours"].blank? || !t[1]["time_in(4i)"].blank? || !t[1]["time_in(5i)"].blank? || !t[1]["time_out(4i)"].blank? || !t[1]["time_out(5i)"].blank?
       test_array.push("true")
      end

    end #End Of Iteration for week_params
    if error_activity_list.present?&& error_activity_list.count>0
      error_activity_list.each do |error_Notice,value|

      notice_detail +=value.to_s+" "
      end
       flash[:alert]= notice_detail
       return redirect_back(fallback_location: projects_path, alert:  notice_detail)
    end
    test_array
    logger.debug("TEST ARRAY ---------------------#{test_array.inspect}")
        ##
        @user = current_user
        customer = Customer.find(@user.customer_id)
        shift = customer.shifts.where(name: 'Regular', default: true).first
        full_work_day = shift ? shift.regular_hours : 8
        hours_over_month = (full_work_day.to_f/12).to_f
        my_hash  = week_params["time_entries_attributes"]
        ##
    if params[:commit] == "Save Timesheet"
      #####
        old_data = Week.old_data(full_work_day, week.id)
          #returns current_hash
          logger.debug("what is the old_data #{old_data}")
        new_data = Week.new_data(my_hash.to_h, full_work_day, old_data)
          #returns array_to_eval
          logger.debug("what is the new_data #{new_data}")
        final_data = Week.final_data(new_data)
          #returns n_hash
          logger.debug("what is the final_data #{final_data}")
        status = Week.is_vacation_allowed(final_data, @user, full_work_day)
          #returns true or false
          logger.debug("what is the status #{status[:vacation_valid]}")
      ####
          if status[:vacation_valid] == false ### DO NOT SAVE
              logger.debug("Invalid Request!")
              @comment = "Sorry, you only have #{status[:hours_allowed]} hours avaliable, but requested #{status[:hours_requested]} hours"
               flash[:alert] = @comment
               redirect_back(fallback_location: root_path)
          else  ### SAVE THE CHANGES 
              logger.debug("Valid Request!")
              @week.status_id = 5
              @week.time_entries.where(status_id: [nil,1,4]).each do |t|
                t.update(status_id: 5)
              end # End iteration for @week.time_entries
########## MOVED LOGIC
              logger.debug "STATUS ID IS #{week_params[:status_id]}"
              logger.debug "weeks_controller - update - params sent in are #{params.inspect}, whereas week_params are #{week_params}"
              respond_to do |format|
                
                 if @week.update_attributes(week_params) 
                   week_params['time_entries_attributes'].each do |t|
                     logger.debug "weeks_controller - update - forcibly trying to find the activerecord  object for id  #{t[1].inspect} "
                     @week.time_entries.find(t[1]['id'].to_i).update(t[1]) if !t[1]['id'].blank?
  
                     if t[1]["vacation_type_id"].present? && t[1]["partial_day"].nil? && TimeEntry.where(id: t[1]["id"]).present?  
                      TimeEntry.find(t[1]["id"]).update(hours: 0, partial_day: "false")
                    end
                   end
                   
                   
                   logger.debug "weeks_controller - update - After update @week  is #{@week.time_entries.inspect}"
                   params.require(:week).permit(upload_timesheets_attributes: [:time_sheet]).to_h.each do |attr, row|
                     row.each do |i, timesheet|
                       @upload_timesheet = @week.upload_timesheets.create(timesheet) if timesheet.present?
                     end
                   end
                   @week.proxy_user_id = current_user.id
                   @week.proxy_updated_date = Time.now
                   @week.save
                   @week.time_entries.where(user_id: nil).each do |we|
                     we.update(user_id: week_user)  
                     logger.debug("USER IS UPDATED ***************")
                   end
                   @expenses = ExpenseRecord.where(week_id: @week.id)
                   @expenseattachment=ExpenseAttachment.where(expense_record_id: @expenses.ids)
                   logger.debug "THE EXPENSES IN WEEKS-UPDATE #{@expenses.inspect}"
                   create_vacation_request(@week) if params[:commit] == "Submit Timesheet"
                   if @week.status_id == 2
                     ApprovalMailer.mail_to_manager(@week, @expenses, User.find(@week.user_id)).deliver
                   end
                   if @week.status_id == 2
                     format.html { redirect_to "/weeks/#{@week.id}/report", notice: 'Week was successfully updated.' }
                     format.json { render :show, status: :ok, location: @week }
                     #return
                   else
                     format.html { redirect_to "/weeks/#{@week.id}/edit", notice: 'Week was successfully updated.' }
                     format.json { render :show, status: :ok, location: @week }
                     #return
                   end
                 else
                   format.html { render :edit }
                   format.json { render json: @week.errors, status: :unprocessable_entity }
                end
              end
########## END MOVED LOGIC
          end # End Internal If Statement 
    elsif params[:commit] == "Submit Timesheet" 
      #####
        old_data = Week.old_data(full_work_day, week.id)
          #returns current_hash
          logger.debug("what is the old_data #{old_data}")
        new_data = Week.new_data(my_hash.to_h, full_work_day, old_data)
          #returns array_to_eval
          logger.debug("what is the new_data #{new_data}")
        final_data = Week.final_data(new_data)
          #returns n_hash
          logger.debug("what is the final_data #{final_data}")
        status = Week.is_vacation_allowed(final_data, @user, full_work_day)
          #returns true or false
          logger.debug("what is the status #{status[:vacation_valid]}")
      ####
          if status[:vacation_valid] == false ### DO NOT SAVE
              logger.debug("Invalid Request!")
              @comment = "Sorry, you only have #{status[:hours_allowed]} hours avaliable, but requested #{status[:hours_requested]} hours"
               flash[:alert] = @comment
               redirect_back(fallback_location: root_path) #Will deprecate use redirect_back(fallback_location: fallback_location)
          else  ### SAVE THE CHANGES   
            @week.status_id = 2
            @week.time_entries.where(status_id: [nil,1,4,5]).each do |t|
              t.update(status_id: 2)
             end #end of iteration for week.time_entries
########## MOVED LOGIC
              logger.debug "STATUS ID IS #{week_params[:status_id]}"
              logger.debug "weeks_controller - update - params sent in are #{params.inspect}, whereas week_params are #{week_params}"
              respond_to do |format|
                 if @week.update_attributes(week_params) 
                   week_params['time_entries_attributes'].each do |t|
                     logger.debug "weeks_controller - update - forcibly trying to find the activerecord  object for id  #{t[1].inspect} "
                     @week.time_entries.find(t[1]['id'].to_i).update(t[1]) if !t[1]['id'].blank?
                    if t[1]["vacation_type_id"].present? && t[1]["partial_day"].nil? && TimeEntry.where(id: t[1]["id"]).present?  
                      TimeEntry.find(t[1]["id"]).update(hours: 0, partial_day: "false")
                    end
                   end
                   
                   logger.debug "weeks_controller - update - After update @week  is #{@week.time_entries.inspect}"
                   params.require(:week).permit(upload_timesheets_attributes: [:time_sheet]).to_h.each do |attr, row|
                     row.each do |i, timesheet|
                       @upload_timesheet = @week.upload_timesheets.create(timesheet) if timesheet.present?
                     end
                   end
                   @week.proxy_user_id = current_user.id
                   @week.proxy_updated_date = Time.now
                   @week.save
                   @week.time_entries.where(user_id: nil).each do |we|
                     we.update(user_id: week_user)  
                     logger.debug("USER IS UPDATED ***************")
                   end
                   @expenses = ExpenseRecord.where(week_id: @week.id)                   
                   @expenseattachment=ExpenseAttachment.where(expense_record_id: @expenses.ids)
                   logger.debug "THE EXPENSES IN WEEKS-UPDATE #{@expenses.inspect}"
                   create_vacation_request(@week) if params[:commit] == "Submit Timesheet"
                   if @week.status_id == 2
                     ApprovalMailer.mail_to_manager(@week, @expenses, User.find(@week.user_id)).deliver
                   end
                   if @week.status_id == 2
                     format.html { redirect_to "/weeks/#{@week.id}/report", notice: 'Week was successfully updated.' }
                     format.json { render :show, status: :ok, location: @week }
                     #return
                   else
                     format.html { redirect_to "/weeks/#{@week.id}/edit", notice: 'Week was successfully updated.' }
                     format.json { render :show, status: :ok, location: @week }
                     #return
                   end
                 else
                   format.html { render :edit }
                   format.json { render json: @week.errors, status: :unprocessable_entity }
                end
              end 
########## END MOVED LOGIC
          end# End internal if/else 
    end  
    ### Move This 
    #logger.debug "STATUS ID IS #{week_params[:status_id]}"
    #logger.debug "weeks_controller - update - params sent in are #{params.inspect}, whereas week_params are #{week_params}"

    #respond_to do |format|
      # if @week.update_attributes(week_params) 
      #   week_params['time_entries_attributes'].each_with_index  do |t,i|
      #     logger.debug "weeks_controller - update - forcibly trying to find the activerecord  object for id  #{t[1].inspect} "
      #     @week.time_entries.find(t[1]['id'].to_i).update(t[1]) if !t[1]['id'].blank?
      #   end
      #   logger.debug "weeks_controller - update - After update @week  is #{@week.time_entries.inspect}"
      #   params.require(:week).permit(upload_timesheets_attributes: [:time_sheet]).to_h.each do |attr, row|
      #     row.each do |i, timesheet|
      #       @upload_timesheet = @week.upload_timesheets.create(timesheet) if timesheet.present?
      #     end
      #   end
      #   @week.proxy_user_id = current_user.id
      #   @week.proxy_updated_date = Time.now
      #   @week.save
      #   @week.time_entries.where(user_id: nil).each do |we|
      #     we.update(user_id: week_user)  
      #     logger.debug("USER IS UPDATED ***************")
      #   end
      #   @expenses = ExpenseRecord.where(week_id: @week.id)
      #   logger.debug "THE EXPENSES IN WEEKS-UPDATE #{@expenses.inspect}"
      #   create_vacation_request(@week) if params[:commit] == "Submit Timesheet"

      #   if @week.status_id == 2
      #     ApprovalMailer.mail_to_manager(@week, @expenses, User.find(@week.user_id)).deliver
      #   end
      #   if @week.status_id == 2
      #     format.html { redirect_to "/weeks/#{@week.id}/report", notice: 'Week was successfully updated.' }
      #     format.json { render :show, status: :ok, location: @week }
      #   else
      #     format.html { redirect_to "/weeks/#{@week.id}/edit", notice: 'Week was successfully updated.' }
      #     format.json { render :show, status: :ok, location: @week }
      #   end
      # else
      #   format.html { render :edit }
      #   format.json { render json: @week.errors, status: :unprocessable_entity }
      #end
    #end
  ############ End Move This 
  end
  
  def proxy_week
    @user = User.find(params[:user_id])
    logger.debug "@user #{@user.inspect}"
    @proxy = Project.find(params[:proxy_id])
    logger.debug "@proxy #{@proxy.inspect}"
    @proxy_user = User.find(params[:proxy_user])
    logger.debug "@proxy_user #{@proxy_user.inspect}"
    @weeks = Week.where("user_id = ?", params[:proxy_user]).order(start_date: :desc).limit(10)
    logger.debug "@weeks #{@weeks.inspect}"
  end
  
  def report
    @print_report = "false"
    @print_report = params[:hidden_print_report] if !params[:hidden_print_report].nil?
    @week = Week.find(params[:id])
    @expenses = ExpenseRecord.where(week_id: @week.id)
    @expenseattachment=ExpenseAttachment.where(expense_record_id: @expenses.ids)
    @user_name = User.find(@week.user_id)
    @projects = @user_name.projects
    logger.debug "PROJECT quotes: #{!params[:project] == ''}"
    logger.debug "PROJECT nil: #{!params[:project] == nil}"
    logger.debug "PROJECT 1: #{!params[:project] == '5'}"
    logger.debug "PROJECT value: #{params[:project]}"
    logger.debug "commit: #{params[:commit]}"
    if !params[:project].blank?
      logger.debug "getting here?"
      @time_entries = TimeEntry.where(project_id: params[:project], week_id: @week.id).order(:date_of_activity)
    else
      @time_entries = TimeEntry.where(week_id: @week.id).order(:date_of_activity)
    end
    @hours_sum = 0
    @time_entries.each do |t|
      if !t.hours.nil?
        @hours_sum += t.hours
      end
    end
    if @week.status_id == 3 && !@week.approved_by.nil?
      @approved_by = User.find(@week.approved_by)
    end
    
  end

  def print_report

  end

  # DELETE /weeks/1
  # DELETE /weeks/1.json
  def destroy
    @week.destroy
    respond_to do |format|
      format.html { redirect_to weeks_url, notice: 'Week was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def expense_records
    @week = Week.find(params[:week_id])   
    if request.get?
      @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=?", @week.user_id ).to_a
      @week_time_entries = TimeEntry.where(project_id: params[:project], week_id: @week.id).order(:date_of_activity)
      @start_date = @week.start_date.to_date
      @end_date = @week.end_date.to_date
      logger.debug("The IN REQUEST GET WEEK STARTDATE #{@start_date.inspect} AND END DATE IS #{@end_date.inspect}")
      @week_dates = @start_date.upto(@end_date)      
      #@expenses = ExpenseRecord.where(week_id: @week.id)
      respond_to do |format|
        format.js
      end
    else
      if !params[:expense_id].present?
          logger.debug("EXPENSE RECORD- #{params.inspect}")
          @expense = ExpenseRecord.new
          @expense.expense_type = params[:expense_type]
          @expense.date = params[:date]
          @expense.description = params[:description]
          @expense.amount = params[:amount]
          @expense.week_id = params[:week_id]
         # @expense.attachment = params[:attachment]
          if !params[:project_id].nil?
            @expense.project_id = Project.find_by_name(params[:project_id]).id
          end
          #logger.debug("EXPENSE FOUND #{@expense.inspect}")
          @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=?", @week.user_id ).to_a
          logger.debug("The PROJECTS ARE #{@projects.inspect}")
          @start_date = @week.start_date.to_date
          @end_date = @week.end_date.to_date
          logger.debug("The WEEK AFTER GET ----------- STARTDATE #{@start_date.inspect} AND END DATE IS #{@end_date.inspect}")
          @week_dates = @start_date.upto(@end_date)
          logger.debug("The 7 DATES ARE #{@week_dates.inspect}")
          @expense.save
          @expense.attachment.url
          @expense.attachment.current_path
          @expense.attachment_identifier          
          if params[:attachment].present?
            params[:attachment].each do |at|            
            @expense_attachment=ExpenseAttachment.new
              @expense_attachment.attachment = at
              @expense_attachment.expense_record_id =@expense.id
              @expense_attachment.save
             # @expense_attachment.attachment.url
             # @expense_attachment.attachment.current_path
             # @expense_attachment.attachment_identifier
              end
        end
        else
          @expense = ExpenseRecord.where(id: params[:expense_id]).last          
          @expense.expense_type = params[:expense_type]
          @expense.date = params[:date]
          @expense.description = params[:description]
          @expense.amount = params[:amount]
          @expense.week_id = params[:week_id]
         # @expense.attachment = params[:attachment]
          if !params[:project_id].nil?
            @expense.project_id = Project.find_by_name(params[:project_id]).id
          end
          #logger.debug("EXPENSE FOUND #{@expense.inspect}")
          @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=?", @week.user_id ).to_a
          logger.debug("The PROJECTS ARE #{@projects.inspect}")
          @start_date = @week.start_date.to_date
          @end_date = @week.end_date.to_date
          logger.debug("The WEEK AFTER GET ----------- STARTDATE #{@start_date.inspect} AND END DATE IS #{@end_date.inspect}")
          @week_dates = @start_date.upto(@end_date)
          logger.debug("The 7 DATES ARE #{@week_dates.inspect}")
          @expense.save
          @expense.attachment.url
          @expense.attachment.current_path
          @expense.attachment_identifier          
          if params[:attachment].present?
            params[:attachment].each do |at|            
            @expense_attachment=ExpenseAttachment.new
              @expense_attachment.attachment = at
              @expense_attachment.expense_record_id =@expense.id
              @expense_attachment.save
             # @expense_attachment.attachment.url
             # @expense_attachment.attachment.current_path
             # @expense_attachment.attachment_identifier
            end
          end
      end
      @expenses = ExpenseRecord.where(week_id: @week.id)
      @expenseattachment=ExpenseAttachment.where(expense_record_id: @expenses.ids)
      logger.debug("EXPENSES COUNT #{@expenses.count}")
      
      redirect_to edit_week_path(@week)
    end
    
    

  end

  def delete_expense 
    @week = Week.find(params[:week_id])
    @expense_row = ExpenseRecord.find(params[:expense].to_i)
    expense_record_id =@expense_row.id
    logger.debug("DELETING THE ROW #{@expense_row.inspect}")
    @expense_row.destroy    
    logger.debug("DELETING THE EXPENSE*******")
    @expense_row_id = params[:week_id]+"_"+params[:expense]
      #@verb = "Removed" 
    #redirect_to edit_week_path(@week)
  end

  def delete_attachment     
    @expense_attachemnt_row = ExpenseAttachment.find(params[:expense_attachment].to_i)
    logger.debug("DELETING THE ROW #{@expense_Attachment_row.inspect}")
    @expense_attachemnt_row.destroy
    logger.debug("DELETING THE EXPENSE Attachement*******")
    @expense = ExpenseRecord.where(id: params[:expense]).last
    @week = Week.find(@expense.week_id)
    @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=?", @week.user_id ).to_a
    @expenseattachment=ExpenseAttachment.where(expense_record_id: @expense.id)
    @start_date = @week.start_date.to_date
      @end_date = @week.end_date.to_date   
    @week_dates = @start_date.upto(@end_date)
    respond_to do |format|
        format.js
    end
      #@verb = "Removed" 
    #redirect_to edit_week_path(@week)
  end


  def edit_expense 
    @week = Week.find(params[:week_id])
    @projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=?", @week.user_id ).to_a
    @expense = ExpenseRecord.where(id: params[:expense]).last
    @expenseattachment=ExpenseAttachment.where(expense_record_id: @expense.id)
    @start_date = @week.start_date.to_date
      @end_date = @week.end_date.to_date   
    @week_dates = @start_date.upto(@end_date)
    respond_to do |format|
        format.js
    end
   
  end

  def time_reject
    logger.debug "time_reject - entering #{params.inspect}"
    @week = Week.find(params[:id])
    @week.status_id = 4
    @week.time_entries.where(project_id: params[:project_id]).each do |t|
      t.update(status_id: 4)
    end
    @week.comments = params[:comments]
    @row_id = params[:row_id]
    @week.save!
    @user = current_user
    ApprovalMailer.mail_to_user(@week, @user, 'Timesheet Rejected').deliver
    logger.debug "time_reject - leaving"
    respond_to do |format|
      # format.html {flash[:notice] = "Reject"}
      format.js
    end
  end

  def create_vacation_request(week)
  #need this logic for saving proper vacation request
  @user = current_user
  customer = Customer.find(@user.customer_id)
  shift = customer.shifts.where(name: 'Regular', default: true).first
  full_work_day = shift ? shift.regular_hours : 8
  #  

    week.time_entries.each do |wtime|
      logger.debug("Inspecting the #{wtime.inspect}")

      if wtime.partial_day == "false"
        hours_used = full_work_day
        partial = "false"
      elsif wtime.partial_day == "true"
        hours_used = full_work_day - wtime.hours
          ### Incase a user hour is greater than regular-work hours
        if hours_used < 0
          hours_used = full_work_day
        end 
        partial = "true" 
      end 
      logger.debug("@createVacationRequest..hours_used #{hours_used} and partial #{partial}")



      if wtime.vacation_type_id.present? 
        user = User.find wtime.user_id
        new_vr = VacationRequest.new
        new_vr.vacation_start_date = wtime.date_of_activity
        new_vr.vacation_end_date = wtime.date_of_activity
        new_vr.user_id = wtime.user_id
        new_vr.customer_id = user.customer_id
        new_vr.comment = "Time Sheet Single Vacation Request"
        new_vr.status = "Requested"
        new_vr.vacation_type_id =wtime.vacation_type_id
        new_vr.partial_day = partial
        new_vr.hours_used = hours_used
        new_vr.save
      end
    end
  end

  def dismiss
    logger.debug"REACHING DISMISS"
    id = params[:week_id]
    logger.debug"IDDDD #{id.inspect}"
    w = Week.find(id)
    logger.debug("inside the dismiss #{w.inspect}")
    w.dismiss = "true"
    logger.debug("after the true in the dismiss #{w.inspect}")
    w.save
    
    @row_id = params[:row_id]
    #@w.approved_date = Time.now.strftime('%Y-%m-%d')
    #@w.approved_by = current_user.id
    #if @w.time_entries.where.not(hours:nil).count == @w.time_entries.where(status_id: 3).count
    #  @w.status_id = 3
    #  @w.save!

    #manager = current_user
    #ApprovalMailer.mail_to_user(@w, manager, 'Timesheet Approval').deliver
    respond_to do |format|
      format.html {flash[:notice] = "dismissed"}
      format.js
    end
  end

  def show_all_timesheets
    @projects = Project.where(user_id: current_user.id)
    respond_to do |format|  
      format.html{}
    end
  end

  def open_previous_week_modal
    @user = User.find params[:user_id]
    @past_weeks = Week.where(user_id: params[:user_id], created_by: current_user.id)
    # if params[:start_date].present?
    #     start_date  = params[:start_date].to_date.strftime('%Y-%m-%d')
    #     end_date = params[:end_date].to_date.strftime('%Y-%m-%d')
    #     @week = Week.new
    #     @week.start_date = start_date
    #     @week.end_date = end_date
    #     @week.user_id = params[:user_id]
    #     @week.created_by = current_user.id
    #     @week.status_id = Status.find_by_status("NEW").id
    #     @week.save!
    # end
    # @week_data = Week.where(user_id: current_user.id) 
    respond_to do |format|
      format.js
    end
  end

  def add_previous_week
    if params[:start_date].present?
        start_date  = params["start_date"].to_date.beginning_of_week
        end_date = start_date.end_of_week
        unless Week.where(start_date: start_date, user_id: params[:user_id]).last.present?
          @week = Week.new
          @week.start_date = start_date
          @week.end_date = end_date
          @week.user_id = params[:user_id]
          @week.created_by = current_user.id
          @week.status_id = Status.find_by_status("NEW").id
          @week.save!
          
          7.times {  @week.time_entries.build( user_id: @week.user_id, status_id: 1 )}
          @week.time_entries.each_with_index do |te, i|
              logger.debug "weeks_controller - edit now for each time_entry we need to set the date  and user_id and also set the hours  to 0"
              logger.debug "year: #{@week.start_date.year}, month: #{@week.start_date.month}, day: #{@week.start_date.day}"
              @week.time_entries[i].date_of_activity = Date.new(@week.start_date.year, @week.start_date.month, @week.start_date.day) + i
              @week.time_entries[i].user_id = @week.user_id
          end
        @week.save!
      end
    end
    @past_weeks = Week.where(user_id: params[:user_id], created_by: current_user.id)
    @user = User.find params[:user_id]

    respond_to do |format|
      format.js { render :file => "weeks/open_previous_week_modal.js.erb"}
    end

  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_week
      @week = Week.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def week_params
      params.require(:week).permit(:id, :start_date, :end_date, :user_id, :status_id, :comments, :time_sheet, :hidden_print_report, :dismiss,
      time_entries_attributes: [:id, :user_id, :project_id, :task_id, :hours, :date_of_activity, :activity_log, :sick, :personal_day, :updated_by, :_destroy, :time_in, :time_out, :vacation_type_id, :partial_day],expense_records_attributes:[:id, :expense_type, :description, :date, :amount, :attachment, :project_id])
    end

    def redirect_to_root
      redirect_to root_path
    end
end