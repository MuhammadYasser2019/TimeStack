class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # GET /projects
  # GET /projects.json
  def index
    logger.debug("project-index- PROJECT ID IS #{params.inspect}")
    @projectsss = Project.where(user_id: current_user.id, inactive: [false, nil]).order(created_at: :asc)
    @projects = Project.where(user_id: current_user.id)
    @weeks  = Week.where("user_id = ?", current_user.id).order(start_date: :desc).limit(5)
    @adhoc_pm_projects = Project.where(adhoc_pm_id: current_user.id)
    @adhoc_pm_project = @adhoc_pm_projects.first
    @adhoc = params["adhoc"]
    @default_project = current_user.default_project
    @project_tasks = Task.where(project_id: @default_project)
    @terms_modal_show = current_user.terms_and_condition

    @shift_change_requests = ShiftChangeRequest.where("status = ?", "Requested")

    if @projectsss.present?
      params[:project_id] = @project_id = @projectsss.first.id
      logger.debug("project-index- @project_id #{@project_id}")
 
      @users_assignied_to_project = User.joins("LEFT OUTER JOIN projects_users ON users.id = projects_users.user_id AND projects_users.project_id = 1").select("users.email,first_name,email,users.id id,user_id, projects_users.project_id, projects_users.active,project_id")
      @tasks_on_project = Task.where(project_id: @project_id)
      # @applicable_week = Week.joins(:time_entries).where("(weeks.status_id = ? or weeks.status_id = ?) and time_entries.project_id= ? and time_entries.status_id=?", "2", "4","1","2").select(:id, :user_id, :start_date, :end_date , :comments).distinct
      @user_projects = Project.where(user_id: current_user.id)
      @customers = Customer.all
      @project = Project.includes(:tasks).find(@project_id)
      #@applicable_week = Week.joins(:time_entries).where("(weeks.status_id = ? or weeks.status_id = ?) and time_entries.project_id IN (#{@projects.collect(&:id).join(",")}) and time_entries.status_id=?", "2", "4","2").select(:id, :user_id, :start_date, :end_date , :comments).distinct
      @users_on_project = User.joins("LEFT OUTER JOIN projects_users ON users.id = projects_users.user_id AND projects_users.project_id = #{@project.id}").select("users.email,first_name,email,users.id id,user_id, projects_users.project_id, projects_users.active,project_id")
      available_users = User.where("parent_user_id IS ? && (customer_id IS ? OR customer_id = ?)", nil, nil , @project.customer.id) 
      shared_users = SharedEmployee.where(customer_id: @project.customer.id).collect{|u| u.user_id}
      shared_user_array = Array.new
      shared_users.each do |su|
        u = User.find(su)
        shared_user_array.push(u)
      end
      logger.debug("AVAIALABLE SHARED USERS #{shared_users.inspect}, The USER IS #{shared_user_array.inspect}")
      @available_users = available_users + shared_user_array
      @users = User.where("parent_user_id IS null").all
      @invited_users = User.where("invited_by_id = ?", current_user.id)
      @proxies = User.where("customer_id =? and proxy = ?", @project.customer.id, true)
      @customer = Customer.find(@project.customer_id)
      customer_holiday_ids = CustomersHoliday.where(customer_id: @project.customer.id).pluck(:holiday_id)
      @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
      @holiday_exception = HolidayException.new
      @holiday_exceptions = @project.holiday_exceptions
      @adhoc_pm = User.where(id: @project.adhoc_pm_id).first
      @announcement = Announcement.where("active = true").last
    elsif @adhoc_pm_project.present?
      @project = @adhoc_pm_project
      @applicable_week = Week.joins(:time_entries).where("(weeks.status_id = ? or weeks.status_id = ?) and time_entries.project_id= ? and time_entries.status_id=?", "2", "4",@adhoc_pm_project.id,"2").select(:id, :user_id, :start_date, :end_date , :comments).distinct
   end

    respond_to do |format|  
      format.html{}
    end
end

  # GET /projects/1

  # GET /projects/1.json
  def show
    @customers = Customer.all
    @project_id = params[:id]
    @project = Project.includes(:tasks).find(params[:id])
  end

  # GET /projects/new
  def new
    @project = Project.new
    @users_on_project = User.where("parent_user_id IS null").all
    @customer = Customer.find current_user.customer_id
    @configuration = @customer.external_configurations.where(system_type: 'jira').first

  end

  def show_projects
    
    if params["system"].present? && params["system"] == 'jira'
      
      @jira_projects = Project.find_jira_projects(current_user.id)
      if @jira_projects == 'error'
        @error = "Please update valid credentials"
        #render text: @error
        #redirect_to new_project_path
        #redirect_to new_project_path(format: :json)

        #render :json => {:error => @error}
      end
    elsif params["system"].present? && params["system"] == 'redmine'
      @error = "Please update valid credentials"
        #redirect_to new_project_path
      render :json => {:error => @error}
    end

    #respond_to do |format|   
     # format.html { redirect_to new_project_path, error: @error }
      #format.json {render json: error: @error }
      
    #end
  end

  def create_project_from_system
    if  params[:system_type].blank? ||  params[:system_project].blank?
      flash[:error]= 'Please select the fields'
      redirect to new_project_path
    end
    if params[:system_type] == 'jira'
      @jira_project = Project.find_jira_projects(current_user.id, params[:system_project])

      @project = Project.where(external_type_id: @jira_project.id, customer_id: params[:customer_id]).first
      unless @project.present?
        @project = Project.new
        @project.name = @jira_project.name
        @project.customer_id = params[:customer_id]
        @project.user_id = current_user.id
        @project.external_type_id = @jira_project.id
        @project.save
      end 
      @jira_project.issues.each do |issue|
        
        if issue.status.name == 'In Progress'
          unless @project.tasks.where(imported_from: issue.id).present?
            @project.tasks.build(code: issue.key, description: issue.summary, active: true, imported_from: issue.id )
          end
        end
      end

    end
    
    @customers = Customer.all
    @project_id = @project.id
    #render partial: 'new_form' 
  end

  # GET /projects/1/edit
  def edit
    @customers = Customer.all
    @project_id = params[:id]
    @project = Project.includes(:tasks).find(params[:id])
    @applicable_week = Week.joins(:time_entries).where("(weeks.status_id = ? or weeks.status_id = ?) and time_entries.project_id= ? and time_entries.status_id=?", "2", "4",params[:id],"2").select(:id, :user_id, :start_date, :end_date , :comments).distinct
    @users_on_project = User.joins("LEFT OUTER JOIN projects_users ON users.id = projects_users.user_id AND projects_users.project_id = #{@project.id}").select("users.email,first_name,email,users.id id,user_id, projects_users.project_id, projects_users.active,project_id")
    @users = User.where("parent_user_id IS null").all
    @invited_users = User.where("invited_by_id = ?", current_user.id)
    @proxies = User.where(proxy: true)
    @customer = Customer.find(@project.customer_id)
    customer_holiday_ids = CustomersHoliday.where(customer_id: @project.customer.id).pluck(:holiday_id)
    @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
    @holiday_exception = HolidayException.new
    @holiday_exceptions = @project.holiday_exceptions
    @adhoc_pm = User.where(id: @project.adhoc_pm_id).first
  end

  # POST /projects
  # POST /projects.json
  def create
    logger.debug "ID YO #{params[:project][:tasks_attributes].inspect}"
    if params[:project][:tasks_attributes]
      params[:project][:tasks_attributes].each do |t, k|
        logger.debug "T1: #{params[:project][:tasks_attributes][t][:code]}"

        if params[:project][:tasks_attributes][t][:code] == ""
          params[:project][:tasks_attributes].delete t
        end
      end
    end
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to projects_path, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    params[:project_id] = @project_id = params[:id]
    @project = Project.includes(:tasks).find(params[:id])
    pname = params[:project][:name]
    logger.debug "NAME----------------------- #{pname.inspect}"
    @project.update_attributes(name: pname)
    task_attributes = params[:project][:tasks_attributes] if params[:project]
    #previous_codes = Project.previous_codes(@project)
    #task_code = Project.task_value(task_attributes, previous_codes)
    if task_attributes
      task_attributes.permit!.to_h.each do |t|
        logger.debug "CODE: #{t}"
        logger.debug "id: #{t[1]["id"]}"
        if t[1]["id"].blank?
          logger.debug "ID IS NILLLLLLLL"
          t[1]["id"] = Task.all.count + 1
        end
        if Task.where(id: t[1]["id"]).present?
          @task = Task.find(t[1]["id"]).update(code: t[1]["code"], description: t[1]["description"], default_comment: t[1]["default_comment"], active: t[1]["active"], billable: t[1]["billable"], estimated_time: t[1]["estimated_time"], overtime: t[1]["overtime"], imported_from: t[1]["imported_from"])
        else
          @task = Task.create(id: t[1]["id"], code: t[1]["code"], description: t[1]["description"], default_comment: t[1]["default_comment"], active: t[1]["active"], billable: t[1]["billable"],estimated_time: t[1]["estimated_time"], overtime: t[1]["overtime"], imported_from: t[1]["imported_from"], project_id: @project.id)
        end
      end
    end

    logger.debug("############################ the tasks code in projects CONTROLLER #{@task.inspect}")
    logger.debug "PROJECT PARAMS: #{project_params.inspect}"
    pp = project_params.delete("tasks_attributes")
    logger.debug "PROJECT PARAMS AFTER: #{project_params.inspect}"
    logger.debug "PROXY BABY: #{params["proxy"]}"


	  @customers = Customer.all
    @tasks_on_project = Task.where(project_id: @project_id)
    @proxies = User.where("customer_id =? and proxy =?", @project.customer.id, true)
    @customer = Customer.find(@project.customer_id)
    @notifications = project_params[:deactivate_notifications]
    logger.debug("Notifications are:  #{@notifications}")
    @shift_change_requests = ShiftChangeRequest.where("status = ?", "Requested")
		#@applicable_week = Week.joins(:time_entries).where("(weeks.status_id = ? or weeks.status_id = ?) and time_entries.project_id= ? and time_entries.status_id=?", "2", "4",params[:id],"2").select(:id, :user_id, :start_date, :end_date , :comments).distinct    
		@users_on_project = User.joins("LEFT OUTER JOIN projects_users ON users.id = projects_users.user_id AND projects_users.project_id = #{@project.id}").select("users.email,first_name,email,users.id id,user_id, projects_users.project_id, projects_users.active,project_id")
    @users = User.where("parent_user_id IS null").all
    @invited_users = User.where("invited_by_id = ?", current_user.id)
    customer_holiday_ids = CustomersHoliday.where(customer_id: @project.customer.id).pluck(:holiday_id)
    @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
    @holiday_exception = HolidayException.new
    @holiday_exceptions = @project.holiday_exceptions
    @adhoc_pm_project = Project.where(adhoc_pm_id: current_user.id)
    @adhoc_pm = User.where(id: @project.adhoc_pm_id).first
    @project = Project.includes(:tasks).find(params[:id])
    @projects = Project.where(id: params[:project_id])
    @available_users = User.where("parent_user_id IS ? && (customer_id IS ? OR customer_id = ?)", nil, nil , @project.customer.id)
    respond_to do |format|
      if @project.update(customer_id: project_params["customer_id"], proxy: params["proxy"], deactivate_notifications: @notifications)
				format.js
        format.html { redirect_to projects_path, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :index }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.tasks.destroy_all
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def approve
    @w = Week.find(params[:week_id])
    @w.time_entries.where(project_id: params[:id]).each do |t|
      #t.update(status_id: 3, approved_date: Time.now.strftime('%Y-%m-%d'), approved_by: current_user.id)
      t.status_id = 3
      t.approved_date = Time.now.strftime('%Y-%m-%d')
      t.approved_by = current_user.id
      t.save
    end
    @row_id = params[:row_id]
    @w.approved_date = Time.now.strftime('%Y-%m-%d')
    @w.approved_by = current_user.id
    #if @w.time_entries.where.not(hours:nil).count == @w.time_entries.where(status_id: 3).count
      @w.status_id = 3
      @w.save!

    manager = current_user
    ApprovalMailer.mail_to_user(@w, manager, 'Timesheet Approval').deliver
    respond_to do |format|
      format.html {flash[:notice] = "Approved"}
      format.js
    end

  end



  def approve_all
    @pm_projects = Project.where("user_id=?", current_user.id)
    week_ids_array = Array.new

    @pm_projects.each do |p|
      week_ids = Week.joins(:time_entries).where("(weeks.status_id = ? or weeks.status_id = ?) and time_entries.project_id= ? and time_entries.status_id=?", "2", "4",p.id,"2").pluck(:id)
      week_ids_array.push(week_ids)
    end
    

    distinct_week_ids = week_ids_array.flatten
    logger.debug "WEEK IDS ARE #{distinct_week_ids}"

    distinct_week_ids.each do |wid|
      w = Week.find(wid)
      w.time_entries.where(week_id: wid).each do |t|
       t.status_id = 3
       logger.debug " INSIDE OF TIME ENTRY STATUS ID: #{t.status_id}"
       t.approved_date = Time.now.strftime('%Y-%m-%d')
       logger.debug " INSIDE OF TIME APPROVED DATE: #{t.approved_date}"
       t.approved_by = current_user.id
       logger.debug " INSIDE OF TIME ENTRY APPROVED BY: #{t.approved_by}"
       t.save
      end
      w.status_id = 3
      w.approved_date = Time.now.strftime('%Y-%m-%d')
      w.approved_by = current_user.id
      w.save
    end
   

    manager = current_user
    #ApprovalMailer.mail_to_user(@w, manager).deliver
    respond_to do |format|
      format.html {flash[:notice] = "Approved"}
      format.js
    end
    

  end

  def show_project_reports
    @project_id = params[:id]
    @p = Project.find(@project_id)
    @users = @p.users
    @user_array = @users.pluck(:id)
    billable = params[:Tasks]
    @dates_array = @p.find_dates_to_print(params[:proj_report_start_date], params[:proj_report_end_date], params["current_week"], params["current_month"])
    if params[:user] == "" || params[:user] == nil
      @consultant_hash = @p.build_consultant_hash(@project_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], @user_array, params["current_week"], params["current_month"], billable)
    else
      @consultant_hash = @p.build_consultant_hash(@project_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], [params[:user]], params["current_week"], params["current_month"], billable)
    end

    respond_to do |format|
      format.js
      format.xlsx
      format.html{}
     
    end
  end

  def inventory_and_equipment_reports
    @project_id = params[:id]
    @p = Project.find(@project_id)
    @users = @p.users
    @user_array = @users.pluck(:id)
    if params[:user] == "" || params[:user] == nil
      @all_inventories_hash = @p.build_inventory_hash(params[:inv_report_start_date],params[:inv_report_end_date],@user_array, @project_id, params[:submitted_type],params["current_month"])
    else
      @all_inventories_hash = @p.build_inventory_hash(@project_id,params[:inv_report_start_date],params[:inv_report_end_date],[params[:user]],@project_id, params[:submitted_type],params["current_month"])
    end
    respond_to do |format|
      format.html{}
      format.xlsx
      format.js
    end
  end

  def show_hours
    @user_id = params[:user_id]
    @project_id = params[:project_id]
    @week_id = params[:week_id]
    #@hours_expense_record = ExpenseRecord.where("week_id= ? and project_id= ?", @week_id ,@project_id)
    #@hours_expense_record_id = @hours_expense_record.id
    #logger.debug "SHOW HOURS TIME ENRY #{@hours_expense_record_id}"

    @applicable_hours = TimeEntry.where("week_id= ? and project_id= ?", @week_id ,@project_id)
    @expense_Amount  =ExpenseRecord.where("week_id= ? and project_id= ?", @week_id,@project_id).sum(:amount)  
  end

  def show_old_timesheets
    logger.debug("PROJECTS CONTROLLER -> SHOW OLD TIMESHEETS #{params.inspect}")
    @projects = Project.where(user_id: current_user.id)
    @weeks  = Week.where("user_id = ?", current_user.id).order(start_date: :desc)
    @adhoc_pm_projects = Project.where(adhoc_pm_id: current_user.id)
    @adhoc_pm_project = @adhoc_pm_projects.first
    @adhoc = params["adhoc"]
    if @projects.present?
      params[:project_id] = @project_id = @projects.first.id
      logger.debug("project-index- @project_id #{@project_id}")
 
      @users_assignied_to_project = User.joins("LEFT OUTER JOIN projects_users ON users.id = projects_users.user_id AND projects_users.project_id = 1").select("users.email,first_name,email,users.id id,user_id, projects_users.project_id, projects_users.active,project_id")
      @tasks_on_project = Task.where(project_id: @project_id)
      @user_projects = Project.where(user_id: current_user.id)
      @customers = Customer.all
      @project = Project.includes(:tasks).find(@project_id)
      @users_on_project = User.joins("LEFT OUTER JOIN projects_users ON users.id = projects_users.user_id AND projects_users.project_id = #{@project.id}").select("users.email,first_name,email,users.id id,user_id, projects_users.project_id, projects_users.active,project_id")
      available_users = User.where("parent_user_id IS ? && (customer_id IS ? OR customer_id = ?)", nil, nil , @project.customer.id) 
      shared_users = SharedEmployee.where(customer_id: @project.customer.id).collect{|u| u.user_id}
      shared_user_array = Array.new
      shared_users.each do |su|
        u = User.find(su)
        shared_user_array.push(u)
      end
      logger.debug("AVAIALABLE SHARED USERS #{shared_users.inspect}, The USER IS #{shared_user_array.inspect}")
      @available_users = available_users + shared_user_array
      @users = User.where("parent_user_id IS null").all
      @invited_users = User.where("invited_by_id = ?", current_user.id)
      @proxies = User.where("customer_id =? and proxy = ?", @project.customer.id, true)
      @customer = Customer.find(@project.customer_id)
      customer_holiday_ids = CustomersHoliday.where(customer_id: @project.customer.id).pluck(:holiday_id)
      @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
      @holiday_exception = HolidayException.new
      @holiday_exceptions = @project.holiday_exceptions
      @adhoc_pm = User.where(id: @project.adhoc_pm_id).first
    elsif @adhoc_pm_project.present?
      @project = @adhoc_pm_project
      @applicable_week = Week.joins(:time_entries).where("(weeks.status_id = ? or weeks.status_id = ?) and time_entries.project_id= ? and time_entries.status_id=?", "2", "4",@adhoc_pm_project.id,"2").select(:id, :user_id, :start_date, :end_date , :comments).distinct
    end

  respond_to do |format|  
    format.html{}
  end    
  end

  def pending_email
    @user = User.find(params[:user_id])

  end

  def send_project_users_email
    @project = Project.find params[:project_id]
    @available_users = @project.users
  end


  def add_multiple_users_to_send_email
    @project = Project.find params[:project_id]
    all_users = params[:user_email]
    subject = params[:email_subject]
    body = params[:email_body]
    @project.delay.deliver(all_users,subject,body)
    redirect_to send_project_users_email_path(project_id: @project.id)
  end
    
  def add_multiple_users_to_project
    logger.debug(" add_multiple_user_to_project - #{params.inspect}")
    @project = Project.find(params[:project_id])
    @available_users = User.where("parent_user_id IS ? && (shared =? or customer_id IS ? OR customer_id = ?)",nil, true, nil , @project.customer.id)     
    
    (0..(@available_users- @project.users.active_users).count).each  do |i|

      if params["add_user_id_#{i}"].present?
        user = User.find(params["add_user_id_#{i}"])
        if @project.users.inactive_users.include?(user)
           project_user = ProjectsUser.where("project_id = ? && user_id = ? and current_shift=?", @project.id , user.id, true).last
           project_user.sepration_date = nil
           project_user.save
          
        else
          ProjectsUser.create!(project_id: @project.id, user_id: user.id, current_shift: true,active: true)
          #@project.users.push(user)
        end
        @project.save
      end
    end

    respond_to do |format|
      if @second_run
       logger.debug "-----------SECOND RUN-----------"
       format.js
      else
       format.js { render "shift_modal" }
      end
    end
    
  end

  def shift_modal
    user_count = params[:user_count].to_i - 1
    @project = Project.find(params["project_id"])
    @available_users = User.where("parent_user_id IS ? && (shared =? or customer_id IS ? OR customer_id = ?)",nil, true, nil , @project.customer.id)
    (0..user_count).each do |i|
      projects_user = ProjectsUser.where(user_id: params["user_id_#{i}"], project_id: params["project_id"], current_shift: true).last
      projects_user.project_shift_id = params["project_shift_id_#{i}"].to_i
      projects_user.save!
    end
    @second_run = true

    respond_to do |format|
      format.js { render "add_multiple_users_to_project" }
    end
  end

  def remove_multiple_users_from_project
    logger.debug(" remove_multiple_user_from_project - #{params.inspect}")
    @project = Project.find(params[:project_id])
    @available_users = User.where("parent_user_id IS ? && (shared=? or customer_id IS ? OR customer_id = ?)", nil, true, nil , @project.customer.id)
      (0..@project.users.active_users.count).each  do |i|
      if params["remove_user_id_#{i}"].present?
        user = User.find(params["remove_user_id_#{i}"])
        if @project.users.active_users.include?(user)
            project_user = ProjectsUser.where("project_id = ? && user_id = ? && current_shift=?", @project.id , user.id, true).last
            project_user.sepration_date = Time.now.to_date
            project_user.current_shift = false
            project_user.save
          #@project.users.delete(user)
        end
        @project.save
      end
    end

    respond_to do |format|
      format.js
    end
    
  end  

  def set_selected_users
    @sel_inv_users = User.find params[:invetory_users_ids]
    @sel_inv_ids   = params[:invetory_users_ids].map(&:to_s)
    @inv_sel_users = params[:inv_sel_users]
    @project_id    = params[:project_id]
    
    respond_to do |format|
      format.js
    end
  end
  

  def add_user_to_project
   
    pu = ProjectsUser.new
   
    user = User.find(params[:user_id])
    project = Project.find(params[:project_id])
    if project.users.include?(user)
      ps = ProjectsUser.where(project_id: project.id, user_id: user.id)
      ps.project_shift_id = params[:project_shift_id]
      ps.current_shift = true
      ps.save
    else
      ProjectsUser.create!(project_id: project.id, user_id: user.id, current_shift: true, active: true, project_shift_id: params[:project_shift_id])
    end

    respond_to do |format|
     format.js
   end
  end

  def user_time_report
    @user = User.find(params[:user_id])
    logger.debug("user_time_report######## #{params.inspect}")

    @weeks  = Week.where("user_id = ?", @user.id).order(start_date: :desc).limit(10)



  end
  
  def permission_denied
    
  end

  def deactivate_project
    @project = Project.find(params[:id])
    @project.update(inactive: 1)
    redirect_to projects_path
  end

  def reactivate_project
    @project = Project.find(params[:id])
    @project.update(inactive: 0)
    redirect_to projects_path
  end
  
  def add_adhoc_pm
    @project = Project.find(params[:project_id])
    @adhoc_pm = @project.adhoc_pm_id
    @user = User.find(params[:adhoc_pm_id])
    if @adhoc_pm.present? && @adhoc_pm != @user.id
      @project.adhoc_pm_id = nil
      @project.adhoc_start_date = nil
      @project.adhoc_end_date = nil
      @project.save
    end
    @project.adhoc_pm_id = params[:adhoc_pm_id]
    @project.adhoc_start_date = params[:adhoc_start_date]
    @project.adhoc_end_date = params[:adhoc_end_date]
    @project.save
    @adhoc_pm = User.where(id: @project.adhoc_pm_id).first
    respond_to do |format|
      format.js
    end
  end

    def approve_shift_change
      @user = current_user
      
      @sr = params[:sr_id]
      @row_id = params[:row_id]
      customer_manager = current_user
      shift_request = ShiftChangeRequest.find(@sr)
      shift_request.status = "Approved"
      shift_request.approved_by = @user.id
      if shift_request.save!
        current_user_shift = ProjectsUser.where(:user_id => @user.id , :project_id => params[:project_id], :project_shift_id => shift_request.id, :current_shift => true).last
        if current_user_shift.present?
          current_user_shift.current_shift = false
          current_user_shift.save
        end
        new_user_shift = ProjectsUser.create!(:user_id => @user.id , :project_id => params[:project_id], :project_shift_id => shift_request.id, :current_shift => true)
        ShiftMailer.mail_to_shift_requestor(@sr, customer_manager ).deliver
      end

      respond_to do |format|
      format.html {flash[:notice] = "Approved"}
      format.js
    end
  end


  def reject_shift_change
    @sr = params[:sr_id]
    logger.debug("888888888888888888 : #{@sr.inspect}")
    @row_id = params[:row_id]
    customer_manager = current_user
    vacation_request = ShiftChangeRequest.find(@sr)
    vacation_request.status = "Rejected"
    shift_request.rejected_by = @user.id
    vacation_request.save
    ShiftMailer.rejection_mail_to_shift_requestor(@sr, customer_manager ).deliver
    # @user.vacation_start_date = "NULL"
    # @user.vacation_end_date = "NULL"
    # @user.save
    respond_to do |format|
      format.html {flash[:notice] = "Rejected"}
      format.js
    end
  end

  def show_all_projects
    logger.debug("PROJECT CONTROLLER -> SHOW ALL REPORTS #{params.inspect}" )

    if params[:checked] == "true"
      @projectsss = Project.where(user_id: current_user.id).order(created_at: :asc)
      @checked = "true"
      logger.debug("IF BLOCK #{@projects.inspect}---- count: #{@projects.count}")
    else
      @projectsss = Project.where(user_id: current_user.id, inactive: [false, nil]).order(created_at: :asc)
      @checked = "false"
      logger.debug("ELSE BLOCK #{@projects.inspect}     9999      count: #{@projects.count}")
    end
    respond_to do |format|
      format.js
    end
  end

  def dynamic_project_update
    logger.debug("project-dynamic_project_update- PROJECT ID IS #{params.inspect}")
    @project_id = params[:project_id]
    @adhoc = params["adhoc"]
    logger.debug("project-dynamic_project_update- @project_id #{@project_id}")

    #@projects = Project.where(user_id: current_user.id)
    #logger.debug("project-dynamic_project_update- PROJECT ID IS #{@projects.inspect} ********#{@projects.first.id} ")
    @users_assignied_to_project = User.joins("LEFT OUTER JOIN projects_users ON users.id = projects_users.user_id AND projects_users.project_id = 1").select("users.email,first_name,email,users.id id,user_id, projects_users.project_id, projects_users.active,project_id")
    @tasks_on_project = Task.where(project_id: @project_id)
    # @applicable_week = Week.joins(:time_entries).where("(weeks.status_id = ? or weeks.status_id = ?) and time_entries.project_id= ? and time_entries.status_id=?", "2", "4","1","2").select(:id, :user_id, :start_date, :end_date , :comments).distinct
     @user_projects = Project.where(user_id: current_user.id)
  

    @customers = Customer.all
    @project = Project.includes(:tasks).find(@project_id)
    #@applicable_week = Week.joins(:time_entries).where("(weeks.status_id = ? or weeks.status_id = ?) and time_entries.project_id= ? and time_entries.status_id=?", "2", "4",@project_id,"2").select(:id, :user_id, :start_date, :end_date , :comments).distinct
    @users_on_project = User.joins("LEFT OUTER JOIN projects_users ON users.id = projects_users.user_id AND current_shift is true AND projects_users.project_id = #{@project.id}").select("users.email,first_name,email,users.id id,user_id, projects_users.project_id, projects_users.active,project_id")
    #@available_users = User.where("customer_id IS ? OR customer_id = ?", nil , @project.customer.id)
    available_users = User.where("parent_user_id IS ? && (customer_id IS ? OR customer_id = ?)", nil, nil , @project.customer.id) 
    shared_users = SharedEmployee.where(customer_id: @project.customer.id).collect{|u| u.user_id}
    shared_user_array = Array.new
    shared_users.each do |su|
      u = User.find(su)
      shared_user_array.push(u)
    end
    @shift_change_requests = ShiftChangeRequest.where("status = ?", "Requested")
    logger.debug("AVAIALABLE SHARED USERS #{shared_users.inspect}, The USER IS #{shared_user_array.inspect}")
    @available_users = available_users + shared_user_array
    @users = User.where("parent_user_id IS null").all
    @invited_users = User.where("invited_by_id = ?", current_user.id)
    @proxies = User.where("customer_id =? and proxy = ?", @project.customer.id, true)
    @customer = Customer.find(@project.customer_id)
    customer_holiday_ids = CustomersHoliday.where(customer_id: @project.customer.id).pluck(:holiday_id)
    @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
    @holiday_exception = HolidayException.new
    @holiday_exceptions = @project.holiday_exceptions
    @adhoc_pm_project = @project
    @projects = Project.where(id: @project_id)
    @adhoc_pm = User.where(id: @project.adhoc_pm_id).first
    respond_to do |format|  
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :customer_id, :user_id, :proxy, :deactivate_notifications,
      tasks_attributes: [:id, :code, :description, :project_id, :default_comment, :estimated_time, :overtime, :active , :billable, :delete])
    end
end
