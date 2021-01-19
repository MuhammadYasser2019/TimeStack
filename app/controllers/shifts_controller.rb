class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy], except: [:show_shift_reports]

  def index

  end

  def new
    @shift = Shift.new
    @customer_id = params[:customer_id]
    @customer_id = current_user.customer_id unless @customer_id
    @customer = Customer.find(@customer_id)
    @start_time_hour = ""
    @start_time_minute = ""
    @start_time_period = ""
    @end_time_hour = ""
    @end_time_minute = ""
    @end_time_period = ""
    if params[:project_id]
      @project = Project.find(params[:project_id])
      user_array = []
      User.where(id: ProjectUser.where(project_id: @project.id)).each do |user|
        full_name = if user.first_name && user.last_name
                      user.first_name + ' ' + user.last_name
                    else
                      user.email
                    end
        user_array << [full_name, user.id]
      end
      @potential_supervisors = user_array
    end
  end

  def create
    @shift = Shift.new(shift_params)
    if params[:start_time_hour] && params[:end_time_hour]
      start_time = params[:start_time_hour] + ':' + params[:start_time_minute] + " " + params[:start_time_period]
      end_time = params[:end_time_hour] + ':' + params[:end_time_minute] + " " + params[:end_time_period]
      @shift.start_time = start_time
      @shift.end_time = end_time
    end
    if @shift.save
      if params[:type] == 'customer'
        redirect_to customers_path
      elsif params[:type] == 'project'
        redirect_to projects_path
      end
    elsif params[:type] == 'customer'
      flash.now[:error]='The End Time cannot be before the Start Time.'
      redirect_to new_shift_path(params: JSON.parse(@shift.to_json), type: params[:type])
    elsif params[:type] == 'project'
      redirect_to new_shift_path(params: JSON.parse(@shift.to_json), type: params[:type])
    end
  end

  def edit
    if @shift.start_time
      start_time_split = @shift.start_time.split(":")
      @start_time_hour = start_time_split[0]
      @start_time_minute = start_time_split[1].split(" ")[0]
      @start_time_period = start_time_split[1].split(" ")[1]
    end
    if @shift.end_time
      end_time_split = @shift.end_time.split(":")
      @end_time_hour = end_time_split[0]
      @end_time_minute = end_time_split[1].split(" ")[0]
      @end_time_period = end_time_split[1].split(" ")[1]
    end
    @customer_id = @shift.customer_id
    @customer = Customer.find(@customer_id)
    if params[:project_id]
      @project = Project.find(params[:project_id])
      user_array = []
      User.where(id: ProjectsUser.where(project_id: @project.id)).each do |user|
        full_name = if user.first_name && user.last_name
                      user.first_name + ' ' + user.last_name
                    else
                      user.email
                    end
        user_array << [full_name, user.id]
      end
      @potential_supervisors = user_array
    end
  end

  def update
    if params[:start_time_hour] && params[:end_time_hour]
      start_time = params[:start_time_hour] + ':' + params[:start_time_minute] + " " + params[:start_time_period]
      end_time = params[:end_time_hour] + ':' + params[:end_time_minute] + " " + params[:end_time_period]
    end
    if params[:type] == 'customer' && @shift.update(shift_params.merge(start_time: start_time, end_time: end_time))
      redirect_to customers_path
    elsif params[:type] == 'project' && @shift.update(shift_params)
      redirect_to projects_path
    elsif params[:type] == 'customer'
      flash.now[:error]='The End Time cannot be before the Start Time.'
      redirect_to edit_shift_path(@shift.id, type: params[:type])
    elsif params[:type] == 'project'
      redirect_to edit_shift_path(@shift.id, type: params[:type])
    end
  end

  def show
  end

  def destroy
    customer_id = @shift.customer_id
    if @shift.destroy!
      if Shift.where(customer_id: customer_id).count == 1
        Shift.last.update(default: true)
      end
      redirect_to customers_path
    end
  end

  def show_shift_reports
    
    @project = Project.find params[:id]
    @project_shifts = ProjectShift.where(project_id: @project.id)
    @project_users = ProjectsUser.where(project_id: @project.id, current_shift: true)
    all_users = User.where("parent_user_id IS ? && (shared =? or customer_id IS ? OR customer_id = ?)",nil, true, nil , @project.customer.id)     
    @available_users = all_users- @project.users.active_users
  end

  def toggle_shift
    @project = Project.find params[:project_id]
    @partial = params[:partial]
    @project_shifts = ProjectShift.where(project_id: @project.id)
    @project_users = ProjectsUser.where(project_id: @project.id, current_shift: true)
    all_users = User.where("parent_user_id IS ? && (shared =? or customer_id IS ? OR customer_id = ?)",nil, true, nil , @project.customer.id)     
    @available_users = all_users- @project.users.active_users
    respond_to do |format|
      if params[:partial] == "add_user"
        format.js { render :file => "/shifts/add_users_to_shift.js.erb"}
      else
         format.js { render :file => "/shifts/change_shift.js.erb"}
      end
    end
   
  end

  def assign_shift
    if params[:project_id].present? && params[:user_id].present? && params[:project_shift_id].present?
      @project = Project.find params[:project_id]

      old_shift = ProjectsUser.where(project_id: @project.id, current_shift: true, user_id: params[:user_id]).last
      if old_shift && old_shift.project_shift_id != params[:project_shift_id].to_i
        old_shift.current_shift = false
        old_shift.save
        @project_users = ProjectsUser.create!(project_id: @project.id, current_shift: true, user_id: params[:user_id], project_shift_id: params[:project_shift_id])
      elsif old_shift && old_shift.project_shift_id == params[:project_shift_id].to_i
      else
        @project_users = ProjectsUser.create!(project_id: @project.id, current_shift: true, user_id: params[:user_id], project_shift_id: params[:project_shift_id])
        
      end
    end

    @project_shifts = ProjectShift.where(project_id: @project.id)
    @project_users = ProjectsUser.where(project_id: @project.id, current_shift: true)
    all_users = User.where("parent_user_id IS ? && (shared =? or customer_id IS ? OR customer_id = ?)",nil, true, nil , @project.customer.id)     
    @available_users = all_users- @project.users.active_users
  end

  def cm_shift_report
    if params[:type] == 'customer' && (current_user.cm || current_user.proxy_cm)
      @customer = Customer.find(params[:id])
      @shifts = @customer.shifts
    elsif params[:type] == 'project'# && current_user.pm
      @project = Project.find(params[:id])
      @project_shifts = @project.project_shifts
    elsif params[:type] == 'shift_supervisor'
      @project_shift = ProjectShift.find(params[:id])
      @shift = @project_shift.shift
      @employee_count = @project_shift.users.count
    end

  end

  def shift_report
    @user = current_user

    if params[:start_date].present?
      start_date = params[:start_date]
    else
      start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d")
    end
    params[:start_date] = start_date

    if params[:end_date].present?
      end_date = params[:end_date]
    else
      end_date = Time.now.end_of_month.strftime("%Y-%m-%d")
    end
    params[:end_date] = end_date

    @shift = Shift.find(params[:id])
    

    if current_user.cm?
      @customer = Customer.where(user_id: current_user.id)
      if params[:project].present?
        @project_shifts = @shift.project_shifts.where(project_id: params[:project])
      else
        @project_shifts = @shift.project_shifts
      end
      @project_shift_id_selection = @project_shifts.pluck(:id)
      @projects = current_user.projects
    elsif current_user.pm?
      @projects = Project.where(user_id: current_user.id).uniq
      if params[:project].present?
        @project_shifts = ProjectShift.where(project_id: params[:project])
      else
        @project_shifts = ProjectShift.where(project_id: @projects.pluck(:id))
      end
      @project_shift_id_selection = @project_shifts.pluck(:id)
    end

    time_period = start_date..end_date

    if params[:project].present?
      @time_entries = TimeEntry.where(date_of_activity: time_period,project: params[:project].to_i)
    else  
      @time_entries = TimeEntry.where(date_of_activity: time_period)
    end
    @other_shift = @time_entries.where("project_shift_id is null")
    @current_shift = @time_entries.where(project_shift_id: @project_shift_id_selection)

    @hash = {}
    time_range = (end_date.to_date-start_date.to_date).to_i
    @project_shifts.each do |project_shift|
      project_shift.users.each do |u|
        @hash[u.id] = []
        total_hours = @shift.regular_hours*time_range.to_f
        other_shift_hours = @other_shift.where(user_id: u.id).sum(:hours)
        current_shift_hours = @current_shift.where(user_id: u.id).sum(:hours)
        
        extra_hours = current_shift_hours - @shift.regular_hours*time_range.to_f
        overtime = (extra_hours > 0) ? extra_hours : 0.0
        @hash[u.id] << total_hours
        @hash[u.id] << current_shift_hours
        @hash[u.id] << other_shift_hours
        @hash[u.id] << overtime
      end
    end

    # # unless params[:date]
    # #   last_time_entry = TimeEntry.where(project_shift_id: @project_shift_id_selection).last
    # #   params[:date] = last_time_entry.date_of_activity.strftime("%Y-%m-%d")
    # # end

    # #@after_shift = params[:date].to_date <= DateTime.now.to_date
    # if params[:date] && params[:project] && @after_shift
    #   time_period = start_date..end_date
      
    # elsif params[:date] && params[:project]

    # elsif params[:project]
    #   #time_period = params[:date].to_datetime.beginning_of_day..params[:date].to_datetime.end_of_day
    #   #@time_entries = TimeEntry.where(project_shift_id: @project_shift_id_selection, date_of_activity: time_period)
    # elsif params[:date] && @after_shift
    #   @time_entries = TimeEntry.where(project_shift_id: @project_shift_id_selection, project: params[:project].to_i)
    # end
  end

  private

  def set_shift
    @shift = Shift.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(:name, :start_time, :end_time, :regular_hours, :incharge, :active, :default, :location, :capacity, :customer_id, :shift_supervisor_id,:mon,:tue,:wed,:thu,:fri,:sat,:sun)
  end
end
