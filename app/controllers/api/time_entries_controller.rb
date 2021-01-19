module Api
	class TimeEntriesController<BaseController

		api :GET, '/get_weekly_time_entries', "Get weekly time entries for the current user"
		formats ['json']
        def get_weekly_time_entries
            begin
				@user_id = @user.id
				@weeks = Week.where(:user_id=>@user_id).order(:id=> 'desc').select("id as timeEntryID, start_date as startDate, end_date as endDate, status_id as status").order("startDate desc").as_json 
				render json: format_response_json({
					message: 'Weekly entries retrieved!',
					status: true,
					result: @weeks
				})        
			rescue
			    render json: format_response_json({
					message: 'Failed to retrieve weekly time entries!',
					status: false
				})
			end
		end

		api :GET, '/get_daily_time_entries', "Get daily time entries for the week"
		formats ['json']
		param :week_id, String, :desc => "Week id to fetch the time entries for the week", :required => true
		def get_daily_time_entries
			begin
				@week_id = params[:week_id] 

				@entries = TimeEntry.where(:week_id=> @week_id).select("id as entryID, date_of_activity as date, status_id as entryStatus").order("date desc").as_json
				render json: format_response_json({
					message: 'Daily entries retrieved!',
					status: true,
					result: @entries
				})        
			rescue
			    render json: format_response_json({
					message: 'Failed to retrieve daily time entries!',
					status: false
				})
			end
		end	

		api :GET, '/get_time_entry_detail', "Get detail for the time entry"
		formats ['json']
		param :entry_id, String, :desc => "TimeEntry id to fetch the time entry detail information", :required => true
		def get_time_entry_detail
			begin
				@entry_id = params[:entry_id] 

				@entry_detail = TimeEntry.where(:id=> @entry_id).select("id as entryID, date_of_activity as date, activity_log as description, hours as totalHours, project_id as projectID, task_id as taskID, partial_day as partialDay").first.as_json

				render json: format_response_json({
					message: 'Entry detail retrieved!',
					status: true,
					result: @entry_detail
				})        
			rescue
			    render json: format_response_json({
					message: 'Failed to retrieve time entry detail!',
					status: false
				})
			end
		end	

		api :POST, '/save_time_entry', "Save user time entry"
		formats ['json']
		param :entry_data, Hash, :desc => "Entry Detail", :required => true do
			param :id, String, :desc => "Time Entry ID", :required => true
			param :activity_log, String, :desc => "Task description", :required => true
			param :task_id, String, :desc => "Task ID", :required => true
			param :project_id, String, :desc => "Project ID", :required => true
			param :partial_day, [true,false], :desc => "Boolean for Partial day", :required => false
			param :hours, Integer, :desc => "Total hours", :required => false
			param :date_of_activity, String, :desc => "Date of activity", :required => false
		end
		def save_time_entry
			begin
				@time_entry = params[:entry_data]
				@entry_id =  @time_entry[:id]
				@success = false
				if @entry_id>0
					# UPDATE
					@success =  TimeEntry.find(@entry_id).update_attributes(time_entry_params(@time_entry)) 
				else
					# INSERT
					@success =TimeEntry.new(time_entry_params(@time_entry.except(:id))).save
				end

				render json: format_response_json({
					message:@success? "Time entry saved successfully!" : "Failed to save time entry!",
					status: @success
				})        
			rescue
			    render json: format_response_json({
					message: 'Failed to save time entry!',
					status: false
				})
			end
		end	

		api :GET, '/submit_weekly_time_entry', "Submit weekly entries"
		formats ['json']
		param :week_id, Integer, :desc => "Week ID", :required => true
		def submit_weekly_time_entry
			begin
				@week_id = params[:week_id] #12071

				Week.where(:id=> @week_id).update(status_id: 2)
				
				@rows_affected = TimeEntry.where(:week_id=> @week_id).update_all(status_id: 2)

				@success = @rows_affected > 0

				render json: format_response_json({
					message: @success? 'Successfully submitted weekly entry!': "Failed to submit weekly entry!",
					status: @success
				})        
			rescue
			    render json: format_response_json({
					message: 'Failed to submit weekly entry!',
					status: false
				})
			end
		end	

		api :GET, '/delete_time_entry', "Delete the current TimeEntry"
		formats ['json']
		param :entry_id, Integer, :desc => "TimeEntry ID to delete", :required => true
		def delete_time_entry
			begin
				@entry_id = params[:entry_id]

				@entry = TimeEntry.where(:id=> @entry_id, :user_id => @user.id).first
			
				if !@entry.nil?
					@entry.destroy

					render json: format_response_json({
						message: 'Time entry deleted succesfully!',
						status: true
					})
				else
					render json: format_response_json({
						message: 'Time entry not found!',
						status: false
					})
				end
			rescue
			    render json: format_response_json({
					message: 'Failed to delete time entry!',
					status: false
				})
			end
		end	

		api :GET, '/get_user_projects', "Get all projects for the current user"
		formats ['json']
		def get_user_projects
			begin
				default_project_task = User.where(:id=>@user.id).select(:default_project, :default_task).first

                @project_ids = ProjectsUser.where(:user_id=>@user.id, :current_shift=> true).pluck(:project_id)
				@projects=Project.where(:id=> @project_ids).select("id as projectID, name as projectName").as_json

				render json: format_response_json({
					message: 'User projects retrieved!',
					status: true,
					result: {
						projects: @projects,
						defaultProjectID: default_project_task[:default_project],
						defaultTaskID: default_project_task[:default_task]
					}
				})        
			rescue
			    render json: format_response_json({
					message: 'Failed to retrieve user projects!',
					status: false
				})
			end
		end	

		api :GET, '/get_project_tasks', "Get all tasks for project"
		formats ['json']
		param :project_id, Integer, :desc => "Project ID to fetch all tasks", :required => true
		def get_project_tasks
			begin
				@project_id = params[:project_id]
				@tasks=Task.where(:project_id=> @project_id).select("id as taskID, code as taskName").as_json

				render json: format_response_json({
					message: 'Project tasks retrieved!',
					status: true,
					result: @tasks
				})        
			rescue
			    render json: format_response_json({
					message: 'Failed to retrieve projects tasks!',
					status: false
				})
			end
		end	

		private 

		def time_entry_params(entry)
			entry.permit(:date_of_activity, :project_id, :hours, :activity_log, :task_id, :week_id, :user_id, :sick, :partial_day, :personal_day, :updated_by)
		end
    end
end