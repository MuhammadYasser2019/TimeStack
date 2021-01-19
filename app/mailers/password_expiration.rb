class PasswordExpiration < ActionMailer::Base

	default from: 'technicalsupport@resourcestack.com'

	def mail_for_expiration_to_user(user,token)
		@token = token
		@user = user
		
		mail(to: user.email, subject:"IMPORTANT: ChronStack Account Password Expiring")
		
	end

	 def password_changed(id)
	    @user = User.find(id)
	    mail to: @user.email, subject: "Reset Password Confirmation"
	  end

end