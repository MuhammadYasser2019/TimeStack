class ApprovalMailer < ActionMailer::Base
  default from: 'technicalsupport@resourcestack.com'

  def mail_to_manager(week, expense, user)
    te = TimeEntry.where("week_id = ? AND user_id = ? and project_id IS NOT NULL", week.id, week.user_id).first
    unless te.nil?
      use = Project.find(te.project_id).user_id
      if !use.nil?
        @manager = User.find(use).email
      else
        @manager = "sameer.sharma@resourcestack.com"
      end
      @week = week
      @expenses = expense
      @sender = user.email
      mail(to: @manager , subject:"Time sheet submitted for approval" )
    end
  end

  def mail_to_user(week, user, subject)
    normal_user = User.find(week.user_id)
    if normal_user.parent.present?
      @user = normal_user.parent.email
    else
      @user = normal_user.email
    end
    @approver = user.email

    @time = week

    mail(to:@user  , subject: subject)

  end

  def invitation_accepted(inviter,user)
    @invited_by = User.find(inviter)
    inviter_email = User.find(inviter).email
    @user = user
    user_email = user.email

    mail(to:inviter_email, subject: "Invitation Accepted By #{user_email}")

  end
end