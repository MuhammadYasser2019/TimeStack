class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # GET /customers
  # GET /customers.json
  def index
    
    @customers = Customer.where(user_id: current_user.id)
    if !@customers.present? && current_user.proxy_cm
      customer_id = current_user.customer_id.to_s
      @customers = Customer.where(:id => customer_id)
    end
    @weeks  = Week.where("user_id = ?", current_user.id).order(start_date: :desc).limit(5)
    if @customers.present?
      params[:customer_id] = @customers.first.id unless params[:customer_id].present?
      
      @customer = @customers.first
      customer_holiday_ids = CustomersHoliday.where(customer_id: @customer.id).pluck(:holiday_id)
      @projects = @customer.projects
      @pm_projects = Project.where("user_id=?", current_user.id)
      @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
      @customer_holiday = CustomersHoliday.new
      @invited_users = User.where("invited_by_id = ?", current_user.id)
      @users = User.where("parent_user_id IS ? && (customer_id IS ? OR customer_id = ?)", nil, nil , params[:customer_id])
      @employment_type = EmploymentType.where(customer_id: @customer.id)
      @users_eligible_to_be_manager = User.where("customer_id = ? OR admin = ?",@customer.id, 1)
      logger.debug("customer edit- @users_eligible_to_be_manager #{@users_eligible_to_be_manager.inspect}")
      @user_with_pm_role = User.where("customer_id =? and pm=?", @customer.id, true)
      # @users= User.all
      logger.debug("CUSTOMER EMPLOYEES ARE: #{@users.inspect}")
      @vacation_requests = VacationRequest.where("customer_id= ? and status = ?", params[:customer_id], "Requested")
      @adhoc_projects = Project.where("adhoc_pm_id is not null")
      @vacation_types = VacationType.where("customer_id=? && active=?", @customer.id, true)
      @default_project = current_user.default_project
      @project_tasks = Task.where(project_id: @default_project)
      logger.debug("************User requesting VACATION: #{@vacation_requests.inspect} ")
      logger.debug("TRYING TO FIND CUSTOMER LOGGGGGOOOOOOOOOO: #{@customer.logo}")
      @current_systems = ExternalConfiguration.where(customer_id: @customer.id)
      @terms_modal_show = current_user.terms_and_condition
      @announcement = Announcement.where("active = true").last
      
    end
  end 

  # GET /customers/1
  # GET /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new 
    @users_eligible_to_be_manager = User.where("admin = ?", 1)
  end

  # GET /customers/1/edit
  def edit
    customer_holiday_ids = CustomersHoliday.where(customer_id: @customer.id).pluck(:holiday_id)
    @projects = @customer.projects
    @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
    @customer_holiday = CustomersHoliday.new
    @invited_users = User.where("invited_by_id = ?", current_user.id)
    @users = User.where("parent_user_id IS ? && (customer_id IS ? OR customer_id = ?)", nil, nil , params[:id])
    @employment_type = EmploymentType.where(customer_id: @customer.id)
    @users_eligible_to_be_manager = User.where("customer_id = ? OR admin = ?",@customer.id, 1)
    logger.debug("customer edit- @users_eligible_to_be_manager #{@users_eligible_to_be_manager.inspect}")

    # @users= User.all
    logger.debug("CUSTOMER EMPLOYEES ARE: #{@users.inspect}")
    @vacation_requests = VacationRequest.where("customer_id= ? and status = ?", params[:id], "Requested")
    @adhoc_projects = Project.where("adhoc_pm_id is not null")
    logger.debug("************User requesting VACATION: #{@vacation_requests.inspect} ")
    logger.debug("TRYING TO FIND CUSTOMER LOGGGGGOOOOOOOOOO: #{@customer.logo}")
  end

  # POST /customers
  # POST /customers.json
  def create
    @users_eligible_to_be_manager = User.where("customer_id = ? OR admin = ?",@customer.id, 1)
    @customer = Customer.new(customer_params)
    @customer.user_id = current_user.id
    @customer.theme = "Orange" 
    respond_to do |format|
      if @customer.save
        # add default 9-5 shift
        default_shift = Shift.new
        default_shift.name = "Regular"
        default_shift.start_time = "9:00AM"
        default_shift.end_time = "5:00PM"
        default_shift.regular_hours = 8
        default_shift.incharge = nil
        default_shift.active = false
        default_shift.default = true
        default_shift.location = nil
        default_shift.capacity = nil
        default_shift.customer_id = @customer.id
        default_shift.save!
        format.html { redirect_to customers_path, notice: 'Customer was successfully created.' }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    if params[:customer].blank?
      params[:customer] =params
    end
    @customer.user_id = params[:customer][:user_id].present? ? params[:customer][:user_id] : @customer.user_id
    logger.debug("THIS IS THE CUSTOMER UPDATE METHOD")
    params[:customer_id] = @customer.id
    customer_holiday_ids = CustomersHoliday.where(customer_id: @customer.id).pluck(:holiday_id)
    @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
    @customer_holiday = CustomersHoliday.new
    @invited_users = User.where("invited_by_id = ?", current_user.id)
    @users = User.where("parent_user_id IS ? && (customer_id IS ? OR customer_id = ?)", nil, nil , params[:customer_id])
    
    @employment_type = EmploymentType.where(customer_id: @customer.id)
    @users_eligible_to_be_manager = User.where("customer_id = ? OR admin = ?",@customer.id, 1)
    logger.debug("customer edit- @users_eligible_to_be_manager #{@users_eligible_to_be_manager.inspect}")

    # @users= User.all
    @user_with_pm_role = User.where("customer_id =? and pm=?", @customer.id, true)
    logger.debug("CUSTOMER EMPLOYEES ARE: #{@users.inspect}")
    @vacation_requests = VacationRequest.where("customer_id= ? and status = ?", params[:customer_id], "Requested")
    @adhoc_projects = Project.where("adhoc_pm_id is not null")
    @customer.save
    @vacation_types = VacationType.where("customer_id=? && active=?", @customer.id, true)
    logger.debug("CHECK FOR CUSTOMER params#{@cutomer.inspect}")
    @current_systems = ExternalConfiguration.where(customer_id: @customer.id)
    respond_to do |format|
      if @customer.update(customer_params)
    	  @projects = @customer.projects
	      format.js
        format.html { redirect_to customers_path, notice: 'Customer was successfully updated.' }
        format.json { redirect_to "/customers/#{params[:id]}/theme" }
      else
        format.html { render :index }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def report
    logger "report - params passed are  project_id: #{params[:project_id]},  start_date: #{params[:start_date]}, end_date: #{params[:end_date]}"
    if !params[:project_id].nil?
      logger.debug "report - now  running a report for project  #{params[:project_id]}"
      
    end 
  end
  
  def invite_to_project
    logger.debug "INVITED BY #{params[:invited_by_id]}"
    project = Project.find(params[:project_id])
    project_id = params[:project_id]
    @user = User.invite!(email: params[:email], :invitation_start_date => params[:invite_start_date],:employment_type => params[:employment_type], invited_by_id: params[:invited_by_id].to_i, pm: params[:project_manager], default_project: project_id, shared: params[:shared_user])
    @user.update(invited_by_id: params[:invited_by_id], customer_id: project.customer_id, pm: params[:project_manager])
    pu = ProjectsUser.new
    # @users_on_project = @project.users
    # @users_on_project = params[:user_id]
    # @project = Project.find(1)

    user = User.find(@user.id)
    
    if project.users.include?(user)
      
    else
      project.users.push(user)
    end
    project.save

    redirect_to customers_path
  end

  def customers_pending_email
    logger.debug "CHECKING FOR params[:user_id]  #{params[:user_id]}"
    @cuser = User.find(params[:user_id])
    user_project = ProjectsUser.find_by_user_id(params[:user_id]).project_id
    @project = Project.find(user_project)
  end

  def remove_user_from_customer
    #customer_id = params[:customer_id]
    user = User.find(params[:user_id])
    @row_id = params[:row]
    #logger.debug("CUSTOMER ID: #{customer_id}***********AND USER CUSTOMER ID: #{user.customer_id}")
    if !user.blank?
      user.customer_id = nil
      user.save
      logger.debug("REMOVING THE USER*******")
      @verb = "Removed" 
    end
    respond_to do |format|
     format.js
   end
  end

  def remove_emp_from_vacation
    #customer_id = params[:customer_id]
    etype = EmploymentTypesVacationType.where("employment_type_id=? && vacation_type_id=?", params[:emp_id], params[:vacation_id]).first
    @row_id = params[:row]
    #logger.debug("CUSTOMER ID: #{customer_id}***********AND USER CUSTOMER ID: #{user.customer_id}")
    if etype
      etype.destroy 
    end
    respond_to do |format|
      format.js
    end
  end

  def shared_user
    @shuser = User.find params[:user_id]
    @customer = Customer.where("id != ?", params[:customer_id])
    #if @shuser.present?
    #  if @shuser.shared?
     #   @shuser.shared = false
     # else
     #   @shuser.shared = true
     # end
     # @shuser.save
    #end
    respond_to do |format|
      format.js
    end
  end

  def add_shared_users
    if params[:user_id].present? && params[:customer_id].present?
      @shuser = User.find params[:user_id]
      sh_emplyee = SharedEmployee.where("user_id =? and customer_id=?", params[:user_id], params[:customer_id]).first
      if sh_emplyee.present?
        sh_emplyee.destroy!
      else
        SharedEmployee.create!(user_id: params[:user_id], customer_id: params[:customer_id], permanent: false)
      end
    end
    respond_to do |format|
      format.js
    end

  end


  def add_pm_role
    user = User.find params[:user_id]
    if user.present?
      if user.pm?
        user.pm = false
      else
        user.pm = true
      end
      user.save
    end
    respond_to do |format|
      format.js
    end
  end

  def assign_proxy_role
    user = User.find params[:user_id]
    if user.present?
      if user.proxy?
        user.proxy = false
      else
        user.proxy = true
      end
      user.save
    end
    respond_to do |format|
      format.js
    end
  end

  def assign_cm_proxy_role

    user = User.find params[:user_id]
    if user.present?
      if user.proxy_cm?
        user.proxy_cm = false
      else
        user.proxy_cm = true
      end
      user.save
    end
    respond_to do |format|
      format.js
    end
  end

  def edit_customer_user
    logger.debug("customer_controller- edit_customer_user ")
    @user = User.find(params[:user_id])
    user_customer_id = @user.customer_id
    @employment_types = EmploymentType.where(customer_id: user_customer_id )
    respond_to do |format|
      format.html
    end
  end

  def update_user_employment
    logger.debug("customer.controller - update_user_employment ")
    user = User.find(params[:user_id])
    user.employment_type = params[:employment_type]
    #user.email = params[:email]
    user.is_active = params[:is_active].present? ? params[:is_active] : false 
    user.first_name = params[:first_name]
    user.last_name = params[:last_name]
    user.inactive_at = Time.now.to_date if !params[:is_active].present?
    user.save
    respond_to do |format|
      format.html { redirect_to customers_path}
    end
  end

  def employee_profile
    
    @user = User.find(params[:user_id])
    @default_project = @user.default_project
    @default_task = @user.default_task
    @project_tasks = Task.where(project_id: @default_project)
    logger.debug("the project tasks are: #{@project_tasks.inspect}")
    @customer_id = @user.customer_id
    @vacation_types = VacationType.where("customer_id=? and paid=?", @customer_id, true)         
    
    s_year = Date.today.strftime('%Y').to_i
    start_date = s_year.to_s + "-01-01"

    @sss = start_date
    end_date = Date.today
    @eee = end_date
    emp_type = EmploymentType.where(id: @user.employment_type).last
    @customer_types = emp_type.vacation_types 

    #@customer_types = @vacation_types.distinct{|x| x.id} 
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

  def cancel_vacation_request
    #change the value for this vacation_id
    vr = VacationRequest.find(params[:vacation_id])
      vr.status = "CancelRequest"
    vr.save

    logger.debug("This is the vacation #{vr}")
    #Change the ID
    @row_id = params[:vacation_id]
    respond_to do |format|
      format.js 
    end
  end 

  def add_configuration
    @customer = Customer.where(id: current_user.customer_id).first
    if @customer.present?
      @configuration = ExternalConfiguration.where(system_type: params[:system_type], customer_id: @customer.id).first
      unless @configuration.present?
        @configuration = ExternalConfiguration.new
        @configuration.system_type = params[:system_type]
        @configuration.url = params[:url]
        @configuration.jira_email = params[:jira_email]
        @configuration.password = params[:password]
        @configuration.confirm_password = params[:confirm_password]
        @configuration.customer_id = @customer.id
        @configuration.created_by = current_user.id
        @configuration.save
      end
    end
    @current_systems = ExternalConfiguration.where(customer_id: current_user.customer_id)

    respond_to do |format|
      format.js
    end
  end

  def remove_configuration
    if params[:id].present?
      @configuration = ExternalConfiguration.find(params[:sys_id])
      @configuration.destroy
    end
    @current_systems = ExternalConfiguration.where(customer_id: params[:ids])

  end

  def pre_vacation_request 
      start_date = params[:start_date]
      end_date = params[:end_date]
      num_days = (end_date.to_date - start_date.to_date).to_i
      num_of_days = num_days + 1 
      ## ex 1-5 to 1-8 = 3... 5(1),6(1),7(1),8(1) = 4
      ###
      @user = current_user
      customer = Customer.find(@user.customer_id)
      shift = customer.shifts.where(name: 'Regular', default: true).first
      full_work_day = shift ? shift.regular_hours : 8
      hours_over_month = (full_work_day.to_f/12).to_f
      ###
      @vacation_type = VacationType.find(params[:vacation_type_id])
      logger.debug("VacationType Is...#{@vacation_type.inspect}")
      if @vacation_type.paid == true
          uvt = VacationRequest.where("vacation_type_id=? and user_id=?",params[:vacation_type_id], @user.id )
          weekend_counter = Customer.holiday_weekend_count(@user, start_date, end_date)
            logger.debug("the weekend/holiday count is #{weekend_counter}")
            correct_days = num_of_days - weekend_counter
            logger.debug(" Days Request - (wknd/holidays) #{correct_days}")
            if correct_days < 0
              #For Some odd reason a user requests a vacation on a holiday that is on a weekend.
              correct_days = 0
            end 
            hours_requested = correct_days * full_work_day
          hours_allowed = Customer.is_vacation_allowed(uvt, @vacation_type, @user, full_work_day) 

          if hours_allowed == "BANANA"
            logger.debug("@vacation_type.vacation_bank == 0 || @vacation_type.vacation_bank == nil")
            hours_requested = 0
            hours_allowed = 0
          end 
      else ### VACATIONTYPE.PAID IS FALSE
            hours_requested = 0
            hours_allowed = 0
      end 
      logger.debug("The Important Values.. hr #{hours_requested} and ha #{hours_allowed}")
          ##############should be > 
          if hours_requested.to_f > hours_allowed.to_f 
            logger.debug("NO NOT TODAY!")
              respond_to do |format|
                format.js
                @comment = "Sorry, you only have #{hours_allowed} hours avaliable, but requested #{hours_requested} hours"
              end 
          else
              logger.debug("Success, this should showwww") 
                respond_to do |format|
                  format.js{ render :template => "customers/pre_vacation_request_approve.js.erb" }
                end 
          end
  end

  def vacation_request
    logger.debug("THE PARAMETERS ARE:  #{params.inspect}")
    @user = current_user
    @users_vacations = VacationRequest.where("user_id = ?",@user.id)
    emp_type = EmploymentType.find current_user.employment_type
    @vacation_types = emp_type.vacation_types.where("customer_id=? && active=?", @user.customer_id, true)
    user_customer = @user.customer_id 
    #sick_leave = params[:vacation_type_id]
    #personal_leave = params[:personal_leave]
    vacation_start_date = params[:vacation_start_date]
    vacetion_end_date = params[:vacation_end_date]
    reason_for_vacation = params[:vacation_comment]
    customer = Customer.find(@user.customer_id)
    shift = customer.shifts.where(name: 'Regular', default: true).first
    full_work_day = shift ? shift.regular_hours : 8

    if !vacation_start_date.blank?
      days = (params[:vacation_end_date].to_date - params[:vacation_start_date].to_date).to_i
      days_requested = days + 1 
      ## ex 1-5 to 1-8 = 3... 5(1),6(1),7(1),8(1) = 4
      weekend_counter = Customer.holiday_weekend_count(current_user, params[:vacation_start_date].to_date, params[:vacation_end_date].to_date)
      logger.debug("Request #{days_requested} and weekend/holiday #{weekend_counter}")
      correct_days = days_requested - weekend_counter
      if correct_days < 0
          correct_days = 0
      end 
      hours_requested = correct_days * full_work_day

     new_vr = VacationRequest.new
     new_vr.vacation_start_date = params[:vacation_start_date]
     new_vr.vacation_end_date = params[:vacation_end_date]
     new_vr.user_id = @user.id
     new_vr.customer_id = @user.customer_id
     new_vr.comment = reason_for_vacation
     new_vr.status = "Requested"
     new_vr.vacation_type_id = params[:vacation_type_id]
     new_vr.hours_used = hours_requested
     new_vr.save
    end

    #logger.debug("sick_leave: #{sick_leave}******personal_leave: #{personal_leave} ")
    customer_manager = Customer.find(user_customer).user_id
    logger.debug("customer manager id IS : #{customer_manager}")

    #if !vacation_start_date.blank?
    #  VacationMailer.mail_to_customer_owner(@user, customer_manager,vacation_start_date,vacetion_end_date ).deliver
    #  respond_to do |format|
    #    format.html { redirect_to "/", notice: 'Vacation request sent successfully.' }
    #  end
    #end
  end

  def shift_request
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
      @shifts = ProjectShift.where(project_id: @project.id)
      current_project_user = ProjectsUser.where(user_id: current_user.id, project_id: @project.id, current_shift: true).pluck(:project_shift_id)
      @current_shift = ProjectShift.where(id: current_project_user).first
      @shift_array = []
      @shift_array << [@current_shift.shift_name, @current_shift.id] if @current_shift.present?
      if @shifts.count > 1
        @shifts.each do |proj_shift|
          name_and_shift_period = proj_shift.shift_name
          @shift_array << [name_and_shift_period, proj_shift.id]
        end
      end
      @shift_array
      respond_to do|format|
        format.json {render json: @shift_array.as_json()}
      end
    end
  end

  def shift_change_request
    @user = current_user
    users_project_id = ProjectsUser.where(user_id: @user.id, current_shift: true).pluck(:project_id)
    @users_project = Project.find users_project_id
    # current_project_user = ProjectsUser.where(user_id: current_user.id, project_id: @project.id, current_shift: true).pluck(:project_shift_id)
    # @current_shift = ProjectShift.where(id: current_project_user).first
    # #@projects = Project.where(:user_id => 1)
    @user_shift_requests = ShiftChangeRequest.where("user_id = ?",@user.id)
    @selected_project = Project.find_by_id params[:shift_project_id]
    if @selected_project && @selected_project.project_shifts.count ==1
      flash[:error]= "You are currently working on the requested shift"
      redirect_to shift_change_request_path
    else
      if params[:shift_start_date].present? && params[:project_shift_type_id].present?
        @shift_chnge_req = ShiftChangeRequest.new
        @shift_chnge_req.shift_start_date = params[:shift_start_date]
        @shift_chnge_req.shift_end_date = params[:shift_end_date]
        @shift_chnge_req.status = "Requested"
        @shift_chnge_req.comment = params[:comment]
        current_shift = ProjectShift.find params[:current_project_shift_type_id]
        @shift_chnge_req.current_shift_name = current_shift.shift_name if current_shift
        # project shift id from project shift table
        @shift_chnge_req.shift_id = params[:project_shift_type_id]
        @shift_chnge_req.project_id = params[:shift_project_id]
        @shift_chnge_req.user_id = @user.id
        @shift_chnge_req.save!
      end
    end
  end

  def hours_approved
    @shift_id = params[:shift_id]
    @project_id = params[:project_id]
    @users = ProjectsUser.where(project_id: @project_id, current_shift: true, project_shift_id: params[:shift_id])
    @task_id = params[:task_id]
    @start_date = params[:start_date].to_date
    @end_date = params[:end_date].to_date
    @type = params[:type]
    respond_to do |format|
      format.js {render :file => "customers/hours_approved.js.erb" }
    end    
  end

  def users_on_project

    @project = Project.find params[:project_id]
  end  

  def show_pm_projects
    @user = User.find params[:user_id]
    @projects = Project.where(user_id: @user.id)
  end  

  def resend_vacation_request
    logger.debug("RESEND VACATION REQUEST PARAMS: #{params.inspect}")
    user = current_user
    vacation_request = VacationRequest.find(params[:vacation_request_id])
    user_customer = user.customer_id
    customer_manager = Customer.find(user_customer).user_id
    modified_vacation_start_date = params[:vacation_start]
    modified_vacation_end_date = params[:vacation_end]
    vacation_request.vacation_start_date = modified_vacation_start_date
    vacation_request.vacation_end_date = modified_vacation_end_date
    vacation_request.status = "Requested"
    vacation_request.save
    
    # VacationMailer.mail_to_customer_owner(user, customer_manager,modified_vacation_start_date,modified_vacation_end_date ).deliver
    respond_to do |format|
      format.js
    end
  end

  def approve_vacation
    @vr = params[:vr_id]
    logger.debug("888888888888888888 : #{@vr.inspect}")
    @row_id = params[:row_id]
    customer_manager = current_user
    vacation_request = VacationRequest.find(@vr)
    vacation_request.status = "Approved"
    vacation_request.save
    VacationMailer.mail_to_vacation_requestor(@vr, customer_manager ).deliver
    # @user.vacation_start_date = "NULL"
    # @user.vacation_end_date = "NULL"
    # @user.save
    # @dates_array = @user.find_dates_to_print(params[:vacation_start_date], params[:vacation_end_date])

     

    respond_to do |format|
      format.html {flash[:notice] = "Approved"}
      format.js
    end
  end

  def reject_vacation
    @vr = params[:vr_id]
    logger.debug("888888888888888888 : #{@vr.inspect}")
    @row_id = params[:row_id]
    customer_manager = current_user
    vacation_request = VacationRequest.find(@vr)
    vacation_request.status = "Rejected"
    vacation_request.save
    VacationMailer.rejection_mail_to_vacation_requestor(@vr, customer_manager ).deliver
    # @user.vacation_start_date = "NULL"
    # @user.vacation_end_date = "NULL"
    # @user.save
    respond_to do |format|
      format.html {flash[:notice] = "Rejected"}
      format.js
    end
  end

  def approve_cancel_request
    #Create A Mailer
    @vr = params[:vr_id]
    logger.debug("888888888888888888 : #{@vr.inspect}")
    @row_id = params[:row_id]
    customer_manager = current_user
    vacation_request = VacationRequest.find(@vr)
    vacation_request.destroy

    respond_to do |format|
      format.html {flash[:notice] = "Cancellation has been approved"}
      format.js
    end
  end

  def set_theme
    logger.debug("PARAMETERS FOR THEMES ARE: #{params.inspect}")
    user = current_user
    @customer= Customer.find(params[:id])
    logger.debug("THIS IS THE THEME: #{@customer.theme}") 
    theme_selected = params[:theme]
    if !theme_selected.blank?
      @customer.theme = theme_selected
      @customer.save
    end
    @customer_theme = @customer.theme

  end

  def project_reports
    @customer = Customer.find params[:id]
    @projects = @customer.projects
    @shifts = @customer.shifts

    if params[:project_id].present?
      projects = Project.find params[:project_id]
    elsif  params[:exclude_inactive_projects].present? && params[:exclude_inactive_projects] == "true"
      projects = @customer.projects.where("inactive=? or inactive is null", false)
    else
      projects = @customer.projects
    end

    if params[:shift].present?
      shifts = Shift.where(id: params[:shift])
    else
      shifts = @customer.shifts
    end

    @project_report = @customer.build_project_report(projects, shifts, params[:proj_report_start_date], params[:proj_report_end_date], params["current_month"])

    

  end

  def customer_reports
    set_default_reports if params.keys.include?('default')
    
    @customer_id = params[:id]
    @customer = Customer.find(@customer_id)
    default_report = @customer.default_report
    @users = Array.new
    if default_report && !params.keys.include?('button')
      params[:exclude_pending_users] = default_report.exclude_pending_user
      params[:exclude_inactive_users] = default_report.exclude_inactive_users
      params[:Tasks] = default_report.billable
      params[:proj_report_start_date] = default_report.start_date.to_s
      params[:proj_report_end_date] = default_report.end_date.to_s
      params["current_week"] = default_report.current_week
      params["current_month"] = default_report.month
      params[:user] = default_report.user_id
      params[:project] = default_report.project_id
    end

    if params[:exclude_pending_users].present? && params[:exclude_pending_users] == true
      @customer.projects.each do |p|
        @users << p.users.where.not(invitation_accepted_at: nil)
      end
    elsif params[:exclude_inactive_users].present? && params[:exclude_inactive_users] == "true"
      @customer.projects.each do |p|
        @users << p.users.where.not(is_active: false)
      end
    else
      @customer.projects.each do |p|
        @users << p.users
      end
    end
    # @customer.projects.each do |ids|
    #   t = Task.find_by_project_id(ids)
    #   b = t.billable
    #   logger.debug "THE BILLABE VALUES INSIDE LOOP : #{b}"
    # end
    
    billable = params[:Tasks]
    logger.debug "The PARAMS INSIDE CUSTOMER REPORT ARE: #{@billable}"
   
    @users = @users.flatten.uniq
    @users_array = @users.pluck(:id)
    logger.debug("THE USER IDS ARE: #{@users_array}")
    @projects = @customer.projects
    

    @dates_array = @customer.find_dates_to_print(params[:proj_report_start_date], params[:proj_report_end_date], params["current_week"], params["current_month"])
    @week_array = @customer.find_week_id(params[:proj_report_start_date], params[:proj_report_end_date],@users_array)
    logger.debug("THE WEEK ID YOU ARE LOOKING FOR ARE :  #{@week_array}")
    if params[:user] == "" || params[:user] == nil
      if params[:project] == "" || params[:project] == nil
        @consultant_hash = @customer.build_consultant_hash(@customer_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], @users_array, @projects, params["current_week"], params["current_month"], billable)
      else
        @consultant_hash = @customer.build_consultant_hash(@customer_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], @users_array, params[:project], params["current_week"], params["current_month"], billable)
      end
    else
      if params[:project] == "" || params[:project] == nil
        @consultant_hash = @customer.build_consultant_hash(@customer_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], [params[:user]], @projects, params["current_week"], params["current_month"], billable)

      else
        @consultant_hash = @customer.build_consultant_hash(@customer_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], [params[:user]], params[:project], params["current_week"], params["current_month"], billable)
      end

    end
  end

  def inventory_reports
    @customer_id = params[:id]
    @customer = Customer.find(@customer_id)
    @users = Array.new
    
    if params[:exclude_pending_users].present?
      @customer.projects.each do |p|
        @users << p.users.where.not(invitation_accepted_at: nil)
      end
    else
      @customer.projects.each do |p|
        @users << p.users
      end
    end
    @users = @users.flatten.uniq
    @users_array = @users.pluck(:id)
    
    logger.debug("THE USER IDS ARE: #{@users_array}")
    @projects = @customer.projects

    if params[:user] == "" || params[:user] == nil
      if params[:project] == "" || params[:project] == nil
        @all_inventories_hash = @customer.build_inventory_hash(params[:inv_report_start_date],params[:inv_report_end_date],@users_array, @projects, params[:submitted_type],params["current_month"])
      else
        @all_inventories_hash = @customer.build_inventory_hash(params[:inv_report_start_date],params[:inv_report_end_date],@users_array, params[:project], params[:submitted_type],params["current_month"])
      end
    else
      if params[:project] == "" || params[:project] == nil
        @all_inventories_hash = @customer.build_inventory_hash(params[:inv_report_start_date],params[:inv_report_end_date],[params[:user]], @projects, params[:submitted_type],params["current_month"])
      else
        @all_inventories_hash = @customer.build_inventory_hash(params[:inv_report_start_date],params[:inv_report_end_date],[params[:user]], params[:project], params[:submitted_type],params["current_month"])        
      end
    end   
  end

  def add_adhoc_pm_by_cm
    @customer = Customer.find(params[:customer_id])
    @project = Project.find(params[:pm_project_id])
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
    @adhoc_projects = Project.where("adhoc_pm_id is not null")
    respond_to do |format|
      format.js
    end
  end

  def assign_employment_types

    @customer = Customer.find params[:customer_id]
    @employment_type = EmploymentType.where(customer_id: params[:customer_id])
    @employment_type.each do |e|
      etype_vtype = EmploymentTypesVacationType.where("employment_type_id=? and vacation_type_id=?", e.id, params[:vacation_type_id])
      if etype_vtype.blank? && params["employment_type_#{e.id}"] == "1"
        etype_vtype = EmploymentTypesVacationType.new
        etype_vtype.vacation_type_id = params[:vacation_type_id]
        etype_vtype.employment_type_id = e.id
        etype_vtype.save
      end
    end
    @vacation_types = VacationType.where("customer_id=? && active=?", params[:customer_id], true)
    respond_to do |format|
      format.js
    end
  end

  def assign_pm
    @customer = Customer.find params[:id]
    @user_with_pm_role = User.where("customer_id =? and pm=?", @customer.id, true)
    @projects = @customer.projects

    if params["user_id"].present? && params["project_id"].present?      
      @project = Project.find params["project_id"]
      @project.user_id = params["user_id"].to_i
      @project.save

      @projects = @customer.projects
      respond_to do |format|
        format.js
      end
    end
    
  end

  def available_users
    logger.debug "available_users - starting to process, params passed  are #{params[:id]}"
    project_id  = params[:project_id]
    project = Project.find params[:project_id]	
    
    @users = project.users
    logger.debug "available_users - leaving  @users is #{@users}"
    
  end

  def get_employment
    logger.debug "available_emp - starting to process, params passed  are #{params[:vacation_id]}"
    vacation_id  = params[:vacation_id]
    vacation = VacationType.find vacation_id  
    
    @emp = vacation.employment_types
    logger.debug "available_emp - leaving  @emp is #{@emp.inspect}"
  end

  def dynamic_customer_update

    logger.debug("customer-dynamic_customer_update- CUSTOMER ID IS #{params.inspect}")
    @customer = Customer.find params[:customer_id]
    customer_holiday_ids = CustomersHoliday.where(customer_id: @customer.id).pluck(:holiday_id)
	
    @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
    @customer_holiday = CustomersHoliday.new
    @projects = @customer.projects
    @invited_users = User.where("invited_by_id = ?", current_user.id)
    @users = User.where("parent_user_id IS ? && (customer_id IS ? OR customer_id = ?)", nil, nil , params[:customer_id])
    @employment_type = EmploymentType.where(customer_id: @customer.id)
    @users_eligible_to_be_manager = User.where("customer_id = ? OR admin = ?",@customer.id, 1)
    logger.debug("customer-dynamic-update- @users_eligible_to_be_manager #{@users_eligible_to_be_manager.inspect}")
    @user_with_pm_role = User.where("customer_id =? and pm=?", @customer.id, true)
    # @users= User.all
    logger.debug("CUSTOMER EMPLOYEES ARE: #{@users.inspect}")
    # @vacation_requests = VacationRequest.where("customer_id= ? and status = ?", params[:customer_id], "Requested" or "CancelRequest")
    @vacation_requests = VacationRequest.where("customer_id = ? and status IN (?,?)", params[:customer_id],"CancelRequest", "Requested")

    @adhoc_projects = Project.where("adhoc_pm_id is not null")
    @vacation_types = VacationType.where("customer_id=? && active=?", @customer.id, true)
    logger.debug("************User requesting VACATION: #{@vacation_requests.inspect} ")
    logger.debug("TRYING TO FIND CUSTOMER LOGGGGGOOOOOOOOOO: #{@customer.logo}")
	  @current_systems = ExternalConfiguration.where(customer_id: @customer.id)
    @default_project = current_user.default_project
    @project_tasks = Task.where(project_id: @default_project)
    respond_to do |format|  
      format.js
    end
  end

  def questionaire

    email = params[:anything][:email]
    type = params[:anything][:feedback]
    notes = params[:anything][:notes]
    #MyMailer.confirmation_instructions(record, token, current_user).deliver
  
    FeedbackMailer.question_email(email,type,notes).deliver
    
    redirect_back(fallback_location: root_path)

  end 

  def clear_filter
    @default_report = DefaultReport.where(customer_id: current_user.customer_id)
    @default_report.delete_all if @default_report.present?
    redirect_to "/customers/"+"#{current_user.customer_id}"+"/customer_reports"
  end

  def open_edit_customer_modal
    logger.debug("customer.controller - open_edit_customer_modal ")
    @user = User.find(params[:user_id])
    user_customer_id = @user.customer_id
    @employment_types = EmploymentType.where(customer_id: user_customer_id )
     respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:name, :address, :city, :state, :zipcode, :regular_hours, :logo, holiday_ids: [])
    end

    def set_default_reports
      logger.debug("SETTING DEFAULT REPORT")
      @default_report = DefaultReport.where(customer_id: current_user.customer_id).first_or_initialize
      @default_report.customer_id = current_user.customer_id
      @default_report.project_id = params[:project]
      @default_report.user_id = params[:user]
      @default_report.start_date = params[:proj_report_start_date]
      @default_report.end_date = params[:proj_report_end_date]
      @default_report.month = params[:current_month]
      @default_report.current_week = params[:current_week]
      @default_report.exclude_pending_user = params[:exclude_pending_users]
      @default_report.exclude_inactive_users = params[:exclude_inactive_users]
      @default_report.billable = params[:Tasks]
      @default_report.save
      logger.debug("SETTING DEFAULT REPORT: set")
    end

end

