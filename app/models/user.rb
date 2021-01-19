class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # validates :password , presence: true, if: :not_google_account?
  # validates :password_confirmation , presence: true, if: :not_google_account?
  validates :email, presence: true
  #validates :emergency_contact, presence: true
  #validates :first_name, presence: true
  #validates :last_name, presence: true

  mount_uploader :image, ImageUploader
  ## Token Authenticatable
  acts_as_token_authenticatable


  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable, :omniauth_providers => [:google_oauth2]
  devise :timeoutable, :timeout_in => 30.minutes
  devise :password_expirable
  has_many :projects_users
  has_many :projects , :through => :projects_users
  has_many :roles, :through => :user_roles
  has_many :user_roles
  has_many :holiday_exceptions
  has_many :vacation_requests
  has_many :user_notifications
  has_many :project_shifts, through: :projects_users
  has_many :user_recommendations
  has_many :user_disciplinary
  has_many :user_inventory_and_equipments
  has_many :user_devices
  has_many :shift_change_requests
  has_many :user_announcements
  belongs_to :customer

  after_update :send_password_change_email, if: :needs_password_change_email?

  #validates :emergency_contact, format: { with: /\A\d+\z/, message: "Please enter 10 digit minimum contact number." }

  def childs
    self.parent_user_id.present? ? nil : User.where(id: self.parent_user_id)

  end

  def parent
    self.parent_user_id.present? ? User.where(id: self.parent_user_id).first : nil
  end

  def name
    if self.first_name.present? && self.last_name.present?
      return "#{self.first_name}" + " #{ self.last_name}"
    else
      self.email
    end
  end

  def self.approved_week(user,start_date)
    logger.debug(" LOOK LOOK ")
    user = User.where(:email => params[:email])
    approved_week = Week.where(:status_id => 3, :start_date => params[:start_date])  
  end 

  def not_google_account?
    logger.debug("################not google account")
    if google_account == "1"
      logger.debug("##################in the if of no google account")
      return false
    else
      logger.debug("##################in the else of no google account")
      return true
    end
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first
    if user.present?
      user.google_account = true
      user.password_changed_at = Time.now
      user.save
    end

    # Uncomment the section below if you want users to be created if they don't exist
    # unless user
    #     user = User.create(name: data["name"],
    #        email: data["email"],
    #        password: Devise.friendly_token[0,20]
    #     )
    # end
    user
  end

  def self.send_timesheet_notification
    mail_hash = {}
    Project.where("inactive is not true").all.each do |project|
      pm = project.user_id
      next unless pm.present?
      users = []
      project.users.where("is_active is true and pm is not true and cm is not true and admin is not true").each do |u|
        last_week = Week.where("start_date =? and user_id=?", (Date.today-1.week).beginning_of_week, u.id).first
        if last_week && last_week.status_id != 2 && last_week.status_id != 3
          users << u.name
        end
        
      end
      next unless users.present? 

      mail_hash[pm] ||= {}
      mail_hash[pm][project.id] ||= [] 
      mail_hash[pm][project.id] << users
    end  
    
    mail_hash.each do |pm, projects|
      pm = User.find pm
      TimesheetNotificationMailer.mail_to_pm(pm, projects).deliver_now
    end
    last_weeks = Week.where("start_date >=?", Time.now.utc.beginning_of_day-7.days)


    last_weeks.each do |w|
      if w.status_id != 2 || w.status_id != 3
        user = User.find w.user_id
        
        projects = ProjectsUser.where(user_id: user.id, current_shift: true).pluck(:project_id)
        flag_array =  Array.new
        projects.each do |p|
          project = Project.find(p)
          flag_array.push(project.deactivate_notifications)
        end

        if flag_array.include?(false) 
          logger.debug("***************Sending the Notifications to : #{user.inspect}")
          if UserNotification.where("week_id =?", w.id).blank?
            #TimesheetNotificationMailer.mail_to_user(w,user).deliver_now
            User.push_notification(user, w.id)
          end
        end
      end
    end
  end

  def self.push_notification(user, week_id)
    body ="<html>You have not filled your last week timesheet.</html>"
    UserNotification.create(user_id: user.id, 
                            notification_type: "Timesheet Reminder",
                            body: body,
                            week_id: week_id,
                            count: 1, 
                            seen: false)
  end

  def find_dates_to_print(proj_report_start_date = nil, proj_report_end_date = nil)
    if proj_report_start_date.nil?
      start_day = Time.now.beginning_of_week
    else
      start_day = Date.parse(proj_report_start_date)
    end
    
    if proj_report_end_date.nil?
      last_day = start_day.end_of_week
    else
      last_day = Date.parse(proj_report_end_date).end_of_day
    end
    dates_array = []
    this_day = start_day
    while this_day < last_day
      dates_array << this_day.strftime('%m/%d')
      this_day = this_day.tomorrow
      
    end
    logger.debug "DATE ARRAY FOR USER: #{dates_array}"
    return dates_array
  end

  def find_dates_to_print(proj_report_start_date = nil, proj_report_end_date = nil)
    if proj_report_start_date.nil?
      start_day = Time.now.beginning_of_week
    else
      start_day = Date.parse(proj_report_start_date)
    end

    if proj_report_end_date.nil?
      last_day = start_day.end_of_week
    else
      last_day = Date.parse(proj_report_end_date).end_of_day
    end
    dates_array = []
    this_day = start_day
    while this_day < last_day
      dates_array << this_day.strftime('%m/%d')
      this_day = this_day.tomorrow

    end
    logger.debug "DATE ARRAAAAAAAAAAAAAAAAY: #{dates_array}"
    return dates_array
  end

  def full_date_array(proj_report_start_date = nil, proj_report_end_date = nil)
    if proj_report_start_date.nil?
      start_day = Time.now.beginning_of_week
    else
      start_day = Date.parse(proj_report_start_date)
    end

    if proj_report_end_date.nil?
      last_day = start_day.end_of_week
    else
      last_day = Date.parse(proj_report_end_date).end_of_day
    end
    dates_array = []
    this_day = start_day
    while this_day < last_day
      dates_array << this_day
      this_day = this_day.tomorrow

    end
    logger.debug "DATE ARRAAAAAAAAAAAAAAAAY: #{dates_array}"
    return dates_array
  end

  def days_of_week(proj_report_start_date = nil, proj_report_end_date = nil)
    if proj_report_start_date.nil?
      start_day = Time.now.beginning_of_week
    else
      start_day = Date.parse(proj_report_start_date)
    end

    if proj_report_end_date.nil?
      last_day = start_day.end_of_week
    else
      last_day = Date.parse(proj_report_end_date).end_of_day
    end
    dates_array = []
    this_day = start_day
    while this_day < last_day
      dates_array << this_day.strftime('%a')
      this_day = this_day.tomorrow

    end
    logger.debug "DATE ARRAAAAAAAAAAAAAAAAY: #{dates_array}"
    return dates_array
  end

  def user_times(start_date, end_date, user)
    hash_report_data = Hash.new
    customers = user.projects.pluck(:customer_id).uniq
    customers.each do |c|
      projects = Project.where(customer_id: c).pluck(:id)
      time_entries = TimeEntry.where(user_id: user.id, project_id: projects, date_of_activity: start_date..end_date).order(:date_of_activity)
      employee_time_hash = Hash.new
      total_hours = 0
      daily_hours = 0
      time_entries.each do |t|
          if !employee_time_hash[t.date_of_activity.strftime('%m/%d')].blank?
            if employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours].blank?
              daily_hours = t.hours if !t.hours.blank?
              daily_hours = 0 if t.hours.blank?
            else
              daily_hours = employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours] + t.hours if !t.hours.blank?
              daily_hours = employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours] if t.hours.blank?
            end
          else
            daily_hours = !t.hours.blank? ? t.hours : 0
          end

          total_hours = total_hours + t.hours if !t.hours.blank?
          employee_time_hash[t.date_of_activity.strftime('%m/%d')] = { id: t.id, hours: daily_hours, activity_log: t.activity_log }
      end
      u = User.find(c)
      hash_report_data[c] = { daily_hash: employee_time_hash, total_hours: total_hours }
      logger.debug "build_consultant_hash - hash_report_data is #{hash_report_data.inspect}"
     end
    return hash_report_data
  end

  def find_week_id(start_date, end_date,user)
    week_array = []    
      t = TimeEntry.where(user_id: user.id, date_of_activity: start_date..end_date)
      logger.debug("THE T ARE : #{t} and the user is #{user}")
      t.each do |tw|
        week_array << tw.week_id
      end
    week_with_attachment_array = []
    week_array.uniq.each do |w|
      week_with_attachment_array << Week.find(w) if UploadTimesheet.find_by_week_id(w).present?
    end    
    return week_with_attachment_array , week_array

  end

  def active_for_authentication?
    #remember to call the super
    #then put our own check to determine "active" state using 
    #our own "is_active" column
    super and self.is_active?
  end

  def self.generate_jwt_token(user_id , expiry_time = 1.hours.from_now.to_i)
    payload = {'user_id'=> user_id, 'exp'=> expiry_time};
    JWT.encode(payload, jwt_secret)
  end

  def self.decode_jwt_token(authToken)
    token = authToken.present? ? authToken.split(' ')[1]: ''
    HashWithIndifferentAccess.new(JWT.decode(token, jwt_secret)[0])
  rescue
    nil
  end

  def self.send_password_reminder_email
    User.where(is_active: true).each do |u|
      if u.password_changed_at.nil? && Time.now > u.created_at + 86.days && !u.password_reminder_email_sent?
          token, enc = Devise.token_generator.generate(User, :reset_password_token)
          PasswordExpiration.mail_for_expiration_to_user(u,token).deliver
          u.password_reminder_email_sent = true
          u.reset_password_token = enc
          u.reset_password_sent_at = Time.now.utc
          u.save!
      elsif u.password_changed_at.present? && Time.now > u.password_changed_at + 86.days && !u.password_reminder_email_sent?
        token, enc = Devise.token_generator.generate(User, :reset_password_token)
        PasswordExpiration.mail_for_expiration_to_user(u,token).deliver
        u.reset_password_token = enc
        u.password_reminder_email_sent = true
          u.reset_password_sent_at = Time.now.utc
          u.save!
      end
    end
  end

  def self.update_shift_request
    Customer.all.each do |customer|
      default_shift = customer.shifts.where(name: "Regular").first
      customer.projects.each do |project|
        project_shift = ProjectShift.where(project_id: project.id, shift_id: default_shift.id).first
        ShiftChangeRequest.where(status: 'Approved', project_id: project.id).each do |scr|
          
          if scr.shift_end_date > Date.today 
            scr.status = "Expired"
            scr.save
            project_user = ProjectsUser.where(user_id: scr.user_id, project_id: project.id, current_shift: true)
            project_user.project_shift_id = project_shift.id
            project_user.save
          end
        end
      end
        
    end
  end

  def vacation_type
    
    emp_type = EmploymentTypesVacationType.where(employment_type_id: self.employment_type).first
    if emp_type
      vacation_type = VacationType.find emp_type.vacation_type_id
      return vacation_type.vacation_title
    else
      nil
    end
  end

  def self.reset_token
    User.all.each do |u|
      u.authentication_token = nil
      u.save!
    end
  end

  private

  def self.jwt_secret
    YAML.load(File.read('config/jwt-secret.yml'))
  end

  def needs_password_change_email?
    encrypted_password_changed? && persisted?
  end
   
  def send_password_change_email
    PasswordExpiration.password_expirable_changed(id).deliver
  end
end
