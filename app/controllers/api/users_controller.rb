module Api
  class UsersController < BaseController
		include UserHelper
		skip_before_action :authenticate_user, only: [:login_user, :social_login]

		api :POST, '/login_user', "Verify user login and get access"
		formats ['json']
		param :email, String, :desc => "Email Address", :required => true
		param :password, String, :desc => "Password", :required => true
		param :deviceID, String, :desc => "Unique device identifier", :required => true
		param :platform, String, :desc => "Runtime OS (Android/IOS)", :required => true
		param :deviceName, String, :desc => "Unique device name", :required => true
		def login_user	
		  user = User.find_by(email: params[:email])
		  logger.debug("the user email you sent is : #{params[:email]}")
		
			if user&.valid_password?(params[:password])
				user_type = (user.pm? || user.cm? || user.admin?) ?  "admin" : "user"

				UserDevice.save_device_information(user.id, params[:deviceID], params[:platform],params[:deviceName], nil);
				render json: format_response_json(
					{
					  message: 'User logged in succesfully!',
					  status: true,
					  result: {
						  accessToken: user.authentication_token,
						  userRole: user_type,
						  userID: user.id,
						  termsAcknowledged: user.terms_and_condition,
						  tokenExpirationTime: Time.now + 45*60 #45 min duration
					  }
					})
		 	else
				render json: format_response_json(
					{
						message: "The email or password was incorrect. Please try again",
						status: false				
					})
	   		end
		end 

		api :POST, '/social_login', "Verify user login and get access"
		formats ['json']
		param :accessToken, String, :desc => "Google authentication token", :required => true
		param :deviceID, String, :desc => "Unique device identifier", :required => true
		param :platform, String, :desc => "Runtime OS (Android/IOS)", :required => true
		param :deviceName, String, :desc => "Unique device name", :required => true
		def social_login	
			access_token= params[:accessToken]
			user_info = get_information_from_google_token(access_token)
			if user_info.nil?
				render json: format_response_json(
				{
					message: "Invalid social login credential!",
					status: false				
				})
			end
			
			email = user_info["email"]
			user = User.find_by_email(email)
		
			if !user.nil?
				user_type = (user.pm? || user.cm? || user.admin?) ?  "admin" : "user"

				UserDevice.save_device_information(user.id, params[:deviceID], params[:platform],params[:deviceName], nil);
				render json: format_response_json(
					{
					  message: 'User logged in succesfully!',
					  status: true,
					  result: {
						  accessToken: user.authentication_token,
						  userRole: user_type,
						  userID: user.id,
						  termsAcknowledged: user.terms_and_condition,
						  tokenExpirationTime: Time.now + 45*60 #45 min duration
					  }
					})
		 	else
				render json: format_response_json(
					{
					message: "User not found!",
					status: false				
					})
	   		end
		end 

		api :GET, '/agree_to_terms_and_conditions', "Agree terms and conditions"
		formats ['json']
        def agree_to_terms_and_conditions
			begin
				@user.terms_and_condition = true
				@user.save

				render json: format_response_json({
					status: true,
				})
			rescue
			    render json: format_response_json({
					message: 'Failed to agree to terms and conditions!',
					status: false
				})
			end
		end

		api :GET, '/get_customer_detail', "Get current user's customer detail."
		formats ['json']
        def get_customer_detail
            begin
				@customer = @user.customer;

				cur_customer = {:id=> @customer.id, :address=>@customer.address, :city=> @customer.city, :state=>@customer.state, :zipcode=>@customer.zipcode, :customer_name=>@customer.name, :manager_id=> @customer.user_id}

				@manager =User.where(:id=>cur_customer[:manager_id]).select("email").first

				cur_customer = cur_customer.as_json

				cur_customer["manager"] = @manager[:email]

				render json: format_response_json({
					status: true,
					result: cur_customer
				})
			rescue
			    render json: format_response_json({
					message: 'Failed to retrieve employer detail!',
					status: false
				})
			end
		end

		api :GET, '/get_customer_holidays', "Get current user's holidays array."
		formats ['json']
        def get_customer_holidays
            begin
				customer_id = @user.customer_id
				@holidays = CustomersHoliday.where(:customer_id=>customer_id).joins(:holiday).select("date, name, holiday_id as id").order("date asc").as_json

				render json: format_response_json({
					status: true,
					result: @holidays
				})
			rescue
			    render json: format_response_json({
					message: 'Failed to retrieve holiday list!',
					status: false
				})
			end
		end
		  	
		def update_date
    	
			#Used to find week_id for today's time entry 
			user = User.find_by(email: params[:email])
			time_entry = TimeEntry.where("date_of_activity = ? && user_id = ? && (status_id IN (?) or status_id is null)", Date.today.to_datetime, user.id, [1,5,4]).first
			logger.debug("Today's Time Entry #{time_entry.inspect}")
			gimme = time_entry.week_id
			logger.debug("GIMME THAT ID #{gimme}")

			#Find new time_entry with matching parameters
			update_date = TimeEntry.where("date_of_activity = ? and user_id = ? && (status_id IN (?) or status_id is null)", params[:date_of_activity], user.id, [1,5,4])
			logger.debug("the new entry is #{update_date.inspect}")

			#needed for dropdown
			avaliable_entries = TimeEntry.where("week_id = ?", gimme).collect{|w| w.date_of_activity.strftime("%Y/%m/%d")}

			render :json => { status: :ok, 
												timeEntry_hash: { id: update_date[0].id,
																					user_id: update_date[0].user_id,
																					week_id: update_date[0].week_id,
																					task_id: update_date[0].task_id,
																					project_id: update_date[0].project_id,
																					hours: update_date[0].hours,
																					vacation_type_id: update_date[0].vacation_type_id,
																					activity_log: update_date[0].activity_log,
																					date_of_activity: update_date[0].date_of_activity.strftime("%Y/%m/%d"),
																				},
												date_of_activity: avaliable_entries
											}
		end 

		def get_time_entry
			#get user
			user = User.find_by_email(params[:email])
			logger.debug("User ID is #{user.id}")
		
			#Find Current Time Entry
			time_entry = TimeEntry.where("date_of_activity = ? && user_id = ? && (status_id IN (?) or status_id is null)", Date.today.to_datetime, user.id, [1,5,4]).first
			#logger.debug("Today's Time Entry #{time_entry.inspect}")
			if time_entry.present?
				#TimeEntries To Load Into DropDown
				avaliable_entries = TimeEntry.where("week_id = ?", time_entry.week_id).collect{|w| w.date_of_activity.strftime("%Y/%m/%d")}
				logger.debug("These are entries Avaliable #{avaliable_entries.count}")

				#List Projects
				avaliable_projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=?", user.id)
				project_list = []
				avaliable_projects.each do |p|
					project_hash = {id: p.id, name: p.name}
					project_list.push(project_hash)
				end
				logger.debug (" These are the avaliable project's #{avaliable_projects.count}")
				#vacation lists
				emp_type = EmploymentType.find user.employment_type
	    	vacation_types = emp_type.vacation_types.where("customer_id=? && active=?", user.customer_id, true)
				vacation_list = []
				vacation_types.each do |v|
					vacation_hash = {id: v.id, title: v.vacation_title}
					vacation_list.push(vacation_hash)
				end
				logger.debug (" These are the avaliable vacations #{vacation_types.count}")
				

				render :json => { status: :ok, 
													timeEntry_hash: { id: time_entry.id,
																						user_id: time_entry.user_id,
																						week_id: time_entry.week_id,
																						task_id: time_entry.task_id,
																						project_id: time_entry.project_id,
																						hours: time_entry.hours,
																						vacation_type_id: time_entry.vacation_type_id,
																						activity_log: time_entry.activity_log,
																						status_id: time_entry.status_id,
																						date_of_activity: time_entry.date_of_activity.strftime("%Y/%m/%d"),
																					},
													date_of_activity: avaliable_entries,
													avaliable_projects: project_list,
													vacations: vacation_list

												}

			end

		end

		def post_data
			te = TimeEntry.find_by_id(params[:id])
			te.project_id = params[:project]
			te.task_id = params[:task]
			te.vacation_type_id = params[:vacation]
			te.activity_log = params[:activity_log]
			if params[:vacation].present?
					te.hours = 0
				else	
					te.hours = params[:hours]
			end
			te.status_id = 5
			te.save
			week = te.week
			week.status_id = 5
			week.save
			render :json => {status: :ok, message: "Timesheet successfully saved "}

			if params["status"] =="submit"
				week = te.week
				week.status_id = 2
		     	week.time_entries.where(status_id: [nil,1,4,5]).each do |t|
			        t.update(status_id: 2)
				end
				week.save
				return render :json => {status: :ok, message: "Timesheet successfully submitted"}
	    end

		end 


		def submit_week
		#pass the week_id and find all timeEntry's with that week_id
			te = TimeEntry.where(:week_id => params[:week_id])
			te.each do |x|
				x.status_id = 2
				x.save
			end 

			we = Week.find_by_id(params[:week_id])
			we.status_id = 2
				we.save

			return render :json => {status: :ok, message: "Timesheet successfully submitted"}

		end 
		

		def get_tasks
			u = User.find_by_email(params[:email])
			project = Project.where(id: params["project_id"].split(": ").last).first
			task_list = []
			if project.present?
				project.tasks.where(:active=> true).each do |t|
					task_hash = {id: t.id, code: t.description}
					task_list.push(task_hash)
				end
			end
			render :json => {status: :ok, task_hash: {
													avaliable_tasks: task_list																				}
											}
		end

		def get_submitted_timesheet
			user = User.find_by_email params[:email]
			projects = Project.where(user_id: user.id)
				
			timesheet = []
			projects.each do |p|
				applicable_week = Week.joins(:time_entries).where("(weeks.status_id = ?) and time_entries.project_id= ? and time_entries.status_id=?", "2",p.id,"2").select(:id, :user_id, :start_date, :end_date , :comments).distinct
	  		applicable_week.each do |at|
	  			project_hash = {}
	  			project_hash[:id]= at.id
			    project_hash[:project]= p.name
			    project_hash[:employee]= User.find(at.user_id).email
			    project_hash[:start]= at.start_date.strftime('%Y-%m-%d')
			    project_hash[:end]= at.end_date.strftime('%Y-%m-%d')
			    project_hash[:hours]= TimeEntry.where(week_id: at.id, project_id: p.id).sum(:hours)
			    timesheet.push(project_hash)
			  end
			end
			render :json => {status: :ok, timesheet: timesheet}

		end

		def approve
			user = User.find_by_email params[:email]

	    week = Week.find(params[:week_id])
	    project_ids = Project.where(user_id: user.id).collect(&:id)
	    #TODO need to pass project id as well
	    week.time_entries.where(project_id: project_ids).each do |t|
	      t.status_id = 3
    	  t.approved_date = Time.now.strftime('%Y-%m-%d')
    	  t.approved_by = user.id
    	  t.save
      #t.update(status_id: 3, approved_date: Time.now.strftime('%Y-%m-%d'), approved_by: user.id)
	    end

	    week.approved_date = Time.now.strftime('%Y-%m-%d')
	    week.approved_by = user.id
	    week.status_id = 3
	    week.save!

	    manager = user
	    ApprovalMailer.mail_to_user(week, manager, 'TimeSheet Approval').deliver
	    render :json => {status: :ok}

	  end

	
		def reject
			user = User.find_by_email params[:email]

			week = Week.find(params[:week_id])
    	week.status_id = 4
    	project_ids = Project.where(user_id: user.id).collect(&:id)
    	#TODO need to pass project id as well
    	week.time_entries.where(project_id: project_ids).each do |t|
      	t.status_id = 4
      	t.save
    	end
	    #todo pass comment
	    #week.comments = params[:comments]
	    week.save!
	    ApprovalMailer.mail_to_user(week, user, 'Timesheet Rejected').deliver
	    logger.debug "time_reject - leaving"
	 		render :json => {status: :ok}
		end
	end 
end