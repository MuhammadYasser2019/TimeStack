class AnalyticsController < ApplicationController
	def index

    @customer_name = Customer.find(params[:customer_id]).name
    @customer = Customer.find(params[:customer_id])
    cus_users = User.where(customer_id: params[:customer_id])
    @cus_emp_types = EmploymentType.where(customer_id: params[:customer_id]).pluck(:id)
    @cus_emp_names = EmploymentType.where(customer_id: params[:customer_id]).pluck(:name)
    @user_emp_count = Array.new
    @cus_emp_types.each do |cemp|

    user_emp_type = cus_users.where(employment_type: cemp)
    @user_emp_count << user_emp_type.count

    end
	@pieSize = {
        :height => 250, 
	    :width => 500
	}

    colors_array = ["#F7464A", "#46BFBD", "#949FB1", "#4D5360"]
    @pie_data_2 = Array.new
    @cus_emp_types.each_with_index do |cemp, i|

      c_hash = Hash.new
      c_hash["value"] = @user_emp_count[i]
      c_hash["color"] = colors_array[i]
      c_hash["highlight"] = "#FFFF00"
      c_hash["label"] = @cus_emp_names[i]
      @pie_data_2 << c_hash
    end

    @barSize = {
    :height => 350,
    :width => 500
    }


    @cus_projects = Project.where(customer_id: params[:customer_id])
    @customer_id = params[:customer_id]
    @project_ids = @cus_projects.pluck(:id)
    @project_names = Array.new
    @cus_projects.each do |pn|
    	pname = pn.name
    	@project_names << pname[0..10]
    end
    @user_count = Array.new
    @project_ids.each do |pu|
    	@proj_users = ProjectsUser.where(project_id: pu)
    	@user_count << @proj_users.count 
    end
    @bar_data_2 = Hash.new
    @bar_options = Hash.new
    title_hash = Hash.new
    p_hash = Hash.new
    @bar_data_2[:datasets] = Array.new
    @bar_data_2[:labels] = @project_names
    p_hash[:data] = @user_count
    p_hash[:backgroundColor] = colors_array
    p_hash[:highlightFill] = "#000000"
    p_hash[:fillColor] = ["olive", "navy", "red", "orange","purple","magenta", "lime", "yellow", "Green"]
    p_hash[:borderWidth] = 1
    p_hash[:radius] = 2
    p_hash[:label] = "XYZ"
    @bar_options[:title] = Array.new 

    @bar_data_2[:datasets][0] = p_hash

    # Now prepare data for highcharts.

    @user_name = User.where(customer_id: params[:customer_id])
    @user_first_name = Array.new
    @user_sign_in = Array.new
    @user_name.each do |un|
    	@user_first_name << un.first_name
    	#temp_sign_in = un.last_sign_in_at
    	#@user_sign_in << temp_sign_in.to_formatted_s(:short)
        @user_sign_in << un.last_sign_in_at
    end

    @bar_data_3 = Hash.new
    login_hash = Hash.new
    @bar_data_3[:datasets] = Array.new
    @bar_data_3[:labels] = @user_first_name
    login_hash[:data] = @user_sign_in
    login_hash[:backgroundColor] = colors_array
    login_hash[:borderColor] = colors_array
    login_hash[:borderWidth] = 1
    @bar_data_3[:datasets][0] = login_hash


    @lineSize = {
        :height => 350,
        :width => 500
    }

    @month_names = Date::MONTHNAMES

    @line_data = Hash.new
    new_hash = Hash.new
    sub_hash = Hash.new
    appr_hash = Hash.new
    rej_hash = Hash.new

    time_entries_array = Array.new
    week_ids_array = Array.new
    @submitted_count_array = [0,0,0,0,0,0,0,0,0,0,0,0,0]
    @approved_count_array = [0,0,0,0,0,0,0,0,0,0,0,0,0]
    @rejected_count_array = [0,0,0,0,0,0,0,0,0,0,0,0,0]
    @new_count_array = [0,0,0,0,0,0,0,0,0,0,0,0,0]
    all_week_ids_array = Array.new
    #weeks_count_array = Array.new

    @project_ids.each do |pids|
        week_ids_array = TimeEntry.where(project_id: pids).pluck(:week_id).uniq
        all_week_ids_array.push(week_ids_array)
        wids_array_count = week_ids_array.count
        logger.debug("TIME ENTRIES WITH PROJECT ID COUNT #{wids_array_count}")
    end

    logger.debug("WEEK ID #{all_week_ids_array.flatten}")

    all_week_ids_array.flatten.each do |wid|
        logger.debug("WEEK IDS IN THE ARRAY #{wid}")
        w = Week.find(wid)
        if w.status_id == 1 && w.start_date.year == Date.today.year
            logger.debug("WEEK Is           #{w}")
            month = w.start_date.month

            @new_count_array[month] +=1 
            
            logger.debug("MONTH #{month} ,    #{@new_count_array}")

        elsif w.status_id == 2 && w.start_date.year == Date.today.year
            month = w.start_date.month
            @submitted_count_array[month] +=1

        elsif w.status_id == 3 && w.start_date.year == Date.today.year
            month = w.start_date.month
            @approved_count_array[month] +=1

        elsif w.status_id == 4 && w.start_date.year == Date.today.year
            month = w.start_date.month
            @rejected_count_array[month] +=1
        end
    end

    #linedata

    @line_data[:datasets] = Array.new

    @line_data[:labels] = @month_names
    new_hash[:data] = @new_count_array
    new_hash[:lineTension] = 0
    new_hash[:fillColor] = "#006C00"
    new_hash[:borderColor] = 'orange'
    new_hash[:backgroundColor] = 'transparent'
    new_hash[:borderDash] = [5,5]
    new_hash[:borderWidth] = 1
    new_hash[:pointBorderColor] = 'orange'
    new_hash[:pointBackgroundColor] = 'rgba(255,150,0,0.1)'
    new_hash[:pointRadius] = 5
    new_hash[:pointHoverRadius] = 10
    new_hash[:pointHitRadius] = 20
    new_hash[:pointBorderWidth] = 2
    new_hash[:pointStyle] = 'rectRounded'
    new_hash[:label] = "New Weeks"
    #@line_data[:datasets][0] = new_hash
    sub_hash[:data] = @submitted_count_array
    sub_hash[:backgroundColor] = colors_array
    sub_hash[:borderColor] = colors_array
    sub_hash[:borderWidth] = 1
    sub_hash[:fillColor] = "#FF0000"
    sub_hash[:lineTension] = 0
    sub_hash[:label] = "Submitted Weeks"
    #@line_data[:datasets][1] = sub_hash 
    appr_hash[:data] = @approved_count_array
    appr_hash[:backgroundColor] = colors_array
    appr_hash[:borderColor] = colors_array
    appr_hash[:borderWidth] = 1
    appr_hash[:fillColor] = "#00FF00"
    appr_hash[:lineTension] = 0
    appr_hash[:label] = "Approved Weeks"
    #@line_data[:datasets][2] = appr_hash 
    rej_hash[:data] = @rejected_count_array
    rej_hash[:backgroundColor] = colors_array
    rej_hash[:borderColor] = colors_array
    rej_hash[:borderWidth] = 1
    rej_hash[:fillColor] = "#0000FF"
    rej_hash[:lineTension] = 0
    rej_hash[:label] = "Rejected Weeks"
    #@line_data[:datasets][3] = rej_hash 
    @line_data[:datasets] =[new_hash,sub_hash,appr_hash,rej_hash]


    @bar_data_3 = Hash.new
    vac_hash = Hash.new
    @vac_req_count = Array.new
    vacation_request_ids = VacationRequest.where(customer_id: params[:customer_id])
    @vacation_types = VacationType.where(customer_id: params[:customer_id]).pluck(:vacation_title)
    vacation_type_ids = VacationType.where(customer_id: params[:customer_id]).pluck(:id)
    vacation_type_ids.each do |vt|
        vac_req = VacationRequest.where('vacation_type_id = ? AND  vacation_start_date >= ?', vt,"2018-01-01")
        @vac_req_count << vac_req.count
    end

    @bar_data_3[:datasets] = Array.new
    @bar_data_3[:labels] = @vacation_types
    vac_hash[:data] = @vac_req_count
    vac_hash[:backgroundColor] = colors_array
    vac_hash[:borderColor] = colors_array
    vac_hash[:borderWidth] = 1
    vac_hash[:highlightFill] = "#000000"
    vac_hash[:fillColor] = ["olive", "navy", "red", "orange","purple","magenta", "lime", "yellow", "Green"]
    vac_hash[:fill] = false
    vac_hash[:label] = "Vacation"
    @bar_data_3[:datasets][0] = vac_hash 

  end

  def bar_graph
  	#@customer_id = params[:customer_id]
    @cus_projects = Project.where(customer_id: params[:customer_id])
    @customer_id = params[:customer_id]
    @project_id = @cus_projects.pluck(:id)
    @project_names = Array.new
    @cus_projects.each do |pn|
        pname = pn.name
        @project_names << pname[0..10]
    end
    @user_count = Array.new
    @project_id.each do |pu|
        @proj_users = ProjectsUser.where(project_id: pu)
        @user_count << @proj_users.count 
    end
    respond_to do |format|
        format.js
    end
  end

  def vacation_report

    @customer_id = params[:customer_id]
    @customer = Customer.find(params[:customer_id])
    @vac_reqs = VacationRequest.where('customer_id = ? AND  vacation_start_date >= ?', @customer_id,"2018-01-01")

  end

  def user_activities
     @customer = Customer.find(params[:customer_id])
    @customer_id = params[:customer_id]
    @cus_projects = Project.where(customer_id: @customer_id)
    @project_ids = @cus_projects.pluck(:id)
  end

  def vacation_types_summary
        if params[:user_status] == "Not Active"
            is_active = false
        else 
            is_active = true
        end 
            @ooo = is_active
         #If user doesnt pick a date, default is 01-01-thisyear
        if params[:start_date].present?
            start_date = params[:start_date]
        else 
            s_year = Date.today.strftime('%Y').to_i
            start_date = s_year.to_s + "-01-01"
        end 
            @sss = start_date
        #if no end date, today is the end date
        if params[:end_date].present?
            end_date = params[:end_date]
        else 
            end_date = Date.today
        end 
            @eee = end_date
        logger.debug(" Look #{start_date} and #{end_date} and finally #{is_active}")

###
        @customer_id = params[:customer_id]
        #@vacation_types = VacationType.where(customer_id: params[:customer_id])
        @vacation_types = VacationType.where("customer_id=? and paid=?", params[:customer_id], true)         
            @customer_types = @vacation_types.distinct{|x| x.id} 
             customer = Customer.find(params[:customer_id])
             shift = customer.shifts.where(name: 'Regular', default: true).first
             full_work_day = shift ? shift.regular_hours : 8
             logger.debug("full work day #{full_work_day}")
            @users = User.where("customer_id=? and is_active=?", params[:customer_id], is_active)
            logger.debug("what is the USER length #{@users.length}")
            if @users.length > 0
                @user_hash = {}
                @users.each do |user|
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

                        if ct.vacation_bank? && user.vacation_type.present?
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
                         @uvrF = VacationRequest.where("user_id = ? and vacation_type_id = ?", user, ct)
                             d_range = (start_date.to_date .. end_date.to_date)
                             @uvr=[]
                             logger.debug("what is uvr #{@uvr}")
                             @uvrF.each do |ww|
                                    in_range = d_range.cover?(ww.vacation_start_date)
                                    #logger.debug("is #{ww.vacation_start_date.to_date} within #{d_range}... #{in_range}")
                                    if in_range == true
                                        @uvr.push(ww)
                                    end 
                              end 
                              #######
                                currentuser = user.email 
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
            else
            logger.debug("we got here")
            flash[:alert] = "There are no data to display"
               redirect_back fallback_location: root_path
               #redirect_to ("/analytics/vacation_types_summary/"+ params[:customer_id])
            end 
  end 

  def customer_reports
    @customer_id = params[:customer_id]
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
    @dates_array = @customer.find_dates_to_print(params[:proj_report_start_date], params[:proj_report_end_date], params["current_week"], params["current_month"])
    @week_array = @customer.find_week_id(params[:proj_report_start_date], params[:proj_report_end_date],@users_array)
    logger.debug("THE WEEK ID YOU ARE LOOKING FOR ARE :  #{@week_array}")
    if params[:user] == "" || params[:user] == nil
      if params[:project] == "" || params[:project] == nil
        @consultant_hash = @customer.build_consultant_hash(@customer_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], @users_array, @projects, params["current_week"], params["current_month"])
      else
        @consultant_hash = @customer.build_consultant_hash(@customer_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], @users_array, params[:project], params["current_week"], params["current_month"])
      end
    else
      if params[:project] == "" || params[:project] == nil
        @consultant_hash = @customer.build_consultant_hash(@customer_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], [params[:user]], @projects, params["current_week"], params["current_month"])
      else
        @consultant_hash = @customer.build_consultant_hash(@customer_id, @dates_array, params[:proj_report_start_date], params[:proj_report_end_date], [params[:user]], params[:project], params["current_week"], params["current_month"])
      end

    end
  end
end
