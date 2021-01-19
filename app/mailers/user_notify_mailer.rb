class UserNotifyMailer < ActionMailer::Base

default from: 'technicalsupport@resourcestack.com'

def mail_with_subject(users, subject,body)
		
		mail(to: users, subject: subject, body: "Hi, \n" + "#{body}" )
		
	end
end