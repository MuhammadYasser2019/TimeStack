class VacationMailer < ActionMailer::Base

	default from: 'technicalsupport@resourcestack.com'

	def mail_to_customer_owner(user, customer_manager,vacation_start_date,vacetion_end_date )

		@customer_manager_email = User.find(customer_manager).email
		@user_email = user.email
		@vacation_start_date = vacation_start_date
		@vacetion_end_date = vacetion_end_date
		mail(to: @customer_manager_email , subject:"Vacation Request")
	end

	def mail_to_vacation_requestor(vr, customer_manager )
		user = VacationRequest.find(vr).user_id
		@user_email = User.find(user).email
		@customer_manager_email = customer_manager.email
		@vacation_start_date = VacationRequest.find(vr).vacation_start_date
		@vacation_end_date =VacationRequest.find(vr).vacation_end_date
		mail(to: @user_email, subject:"Vacation Request Approved")
	end

	def rejection_mail_to_vacation_requestor(vr, customer_manager )
		user = VacationRequest.find(vr).user_id
		logger.debug("WHAT OS THIS #{user.inspect}")
		@user_email = User.find(user).email
		logger.debug("alskh;saldf #{@user_email.inspect}")
		@customer_manager_email = customer_manager.email
		@vacation_start_date = VacationRequest.find(vr).vacation_start_date
		@vacation_end_date =VacationRequest.find(vr).vacation_end_date
		mail(to: @user_email, subject:"Vacation Request Rejected")
	end

end