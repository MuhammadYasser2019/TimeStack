namespace :update_external_type_id_jira do
	desc "update external type id for project"
	task :update => :environment do
		@userDetails = User.where("pm=?", true)		
		#@jiraCredentials = ExternalConfiguration.where("user_id = ?", @userDetails.ids)				
		@userDetails.each do |u|
			#if u.api_token.present?
				@jira_project = Project.find_jira_projects(u.id)				
				if @jira_project.present?
				@jira_project.each do |project|  

					@project = Project.where(external_type_id: nil, name: project.name, user_id: u.id).first     
					
					if @project.present?
				        @project.external_type_id = project.id
				        @project.save
						project.issues.each do |issue|       
					       active = issue.status.name == 'In Progress'
					       estimate = issue.timeoriginalestimate.present? ? (issue.timeoriginalestimate/3600) : 0

					       @task_details =@project.tasks.where(imported_from: nil, description: issue.summary).first
					       
					        if @task_details.present? 					          
						          @task_details.code = issue.key
						          @task_details.active = active
						          @task_details.estimated_time = estimate
						          @task_details.imported_from = issue.id
						          @task_details.save
					          	  
					        end
					      end
					end
				end
			end
		end
	end	
end