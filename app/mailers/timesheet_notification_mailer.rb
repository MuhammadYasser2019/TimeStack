class TimesheetNotificationMailer < ActionMailer::Base

	default from: 'technicalsupport@resourcestack.com'


	def mail_to_pm(pm, projects)		
			@pm = pm
			@projects = projects
		
			mail(to: @pm.email, subject:"Timesheet Reminder")
		
	end 
end


