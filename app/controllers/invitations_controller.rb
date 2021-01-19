class InvitationsController < Devise::InvitationsController

  #RESEND INVITE ###
  def resend_invite
    User.invite!({:email => params[:email]},current_user)
    redirect_to projects_path
  end
  
  def create
    logger.debug "HELLO NURSE #{params[:user][:project_id]}"
    if params[:user][:customer_id]
      logger.debug "HELLO CUSTOMER ID"
    elsif params[:user][:project_id] != nil
        project_customer_id = Project.find(params[:user][:project_id]).customer_id
        project_id = params[:user][:project_id]
        user = User.invite!({:email => params[:user][:email], :invitation_start_date => params[:invite_start_date],:customer_id => project_customer_id,:default_project => project_id, :employment_type => params[:employment_type]},current_user)
        ProjectsUser.create(user_id: user.id, project_id: params[:user][:project_id])
        project_customer_id = Project.find(params[:user][:project_id])
        logger.debug("invitation controller- create- project_customer_id: #{project_customer_id} ")
        redirect_to projects_path
    else
      super

    end
  end

  def update
    user_params = params[:user]
    logger.debug "IS THIS HAPPENING"
    user_google_account = user_params[:google_account]
    logger.debug("#####################33 user_google_account  #{user_google_account} ")
    user = User.find_by_email(user_params[:email])
    if user_google_account.to_i == 1
      user_data_save
      user.invitation_accepted_at = Time.zone.now.strftime("%Y-%m-%d %H:%M:%S")
      user.save!
      redirect_to user_google_oauth2_omniauth_authorize_path and return
    end
    logger.debug("######create accout #{params.inspect}")
    user_data_save
    Week.weeks_with_invitation_start_date(user)
    super
  end

  def user_data_save
    user_params = params[:user]
    user_google_account = user_params[:google_account]
    logger.debug("#####################33 user_google_account  #{user_google_account} ")
    user = User.find_by_email(user_params[:email])
    user.google_account = user_params[:google_account]
    user.first_name = user_params[:first_name]
    user.last_name = user_params[:last_name]
    user.emergency_contact = user_params[:emergency_contact]
    user.user = 1
    user.save!
    inviter = user.invited_by_id
    ApprovalMailer.invitation_accepted(inviter, user).deliver
  end

end