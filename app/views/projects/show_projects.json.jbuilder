if @jira_projects == 'error'
	
else
	json.array!(@jira_projects) do |p|
	  json.extract! p, :name, :id
	  #json.url user_url(user, format: :json)
	end
end