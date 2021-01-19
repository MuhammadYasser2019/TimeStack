class ShiftMailer < ActionMailer::Base

	default from: 'technicalsupport@resourcestack.com'

	def mail_to_shift_requestor(sr, customer_manager )
		user = ShiftChangeRequest.find(sr).user_id
		@user_email = User.find(user).email
		@customer_manager_email = customer_manager.email
		@request_start_date = ShiftChangeRequest.find(sr).shift_start_date
		@request_end_date =ShiftChangeRequest.find(sr).shift_end_date
		mail(to: @user_email, subject:"Shift Change Request Approved")
	end

	def rejection_mail_to_shift_requestor(sr, customer_manager )
		user = ShiftChangeRequest.find(sr).user_id
		logger.debug("WHAT OS THIS #{user.inspect}")
		@user_email = User.find(user).email
		logger.debug("alskh;saldf #{@user_email.inspect}")
		@customer_manager_email = customer_manager.email
		@request_start_date = ShiftChangeRequest.find(sr).shift_start_date
		@request_end_date =ShiftChangeRequest.find(sr).shift_end_date
		mail(to: @user_email, subject:"Shift Change Request Rejected")
	end

end
