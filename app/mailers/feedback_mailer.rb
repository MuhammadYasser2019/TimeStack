class FeedbackMailer < ActionMailer::Base

	default from: 'technicalsupport@resourcestack.com'


	def question_email(email, type, notes)
		logger.debug("LOOKING FOR THE EMAIL #{email}")
		@email = email
		@type = type
		@notes = notes
		mail(to: 'technicalsupport@resourcestack.com', subject:"You have Feedback") 
	end

	def contact_form_email(email, name, message)
		@email = email
		@name = name
		@message = message
		mail(to: 'technicalsupport@resourcestack.com', subject: "Contact Form -- #{@name}")
	end
end
 