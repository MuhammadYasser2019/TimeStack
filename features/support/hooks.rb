module TestDataSetupHelper


  def create_task
    t = Task.new
    t.id = 1
    t.code = "007"
    t.description = "Test Description"
    # t.project_id = 1
    t.save!
  end

  def create_expense_record
    r = ExpenseRecord.new
    r.id = 1
    r.expense_type = "Travel"
    r.description = "testing"
    r.amount = "100"
    r.save 
  end

  def create_employment_type
    e = EmploymentType.new
    e.id = 1
    e.name = "Contractor"
    e.customer_id = 1
    e.save
  end

  def create_vacation_types
    v = VacationType.new
    v.id = 1
    v.customer_id = 1
    v.employment_type =""
  end


  def create_week
    w = Week.new
    w.id = 1
    #w.user_id = 1
    w.status_id = 1
    w.save
  end

  def create_second_week

    start_date = Date.today.beginning_of_week
    new_week = Week.new
    new_week.id = 3
    new_week.start_date = start_date
    new_week.end_date = start_date.to_date.end_of_week.strftime('%Y-%m-%d') 
    new_week.user_id = 1
    new_week.status_id = 1
    new_week.save
  end

  def create_first_week

    start_date = Date.today.beginning_of_week- 7.days
    new_week = Week.new
    new_week.id = 2
    new_week.start_date = start_date
    new_week.end_date = start_date.to_date.end_of_week.strftime('%Y-%m-%d') 
    new_week.user_id = 1
    new_week.status_id = 1
    new_week.save
  end

  def create_second_week_and_submit
    start_date = Date.today.beginning_of_week
    new_week = Week.new
    new_week.id = 3
    new_week.start_date = start_date
    new_week.end_date = start_date.to_date.end_of_week.strftime('%Y-%m-%d') 
    new_week.user_id = 1
    new_week.status_id = 2
    new_week.save
  end

  def create_time_sheet
    t = TimeEntry.new
    t.project_id = 1
    t.week_id = 2
    t.user_id = 1
    t.hours = 8
    t.date_of_activity = Date.today.beginning_of_week- 7.days
    t.save

    create_expense_records
  end

  def create_second_time_sheet
    t = TimeEntry.new
    t.project_id = 1
    t.week_id = 3
    t.user_id = 1
    t.hours = nil
    t.date_of_activity = Date.today.beginning_of_week
    t.save
  end

  def create_status
    s = Status.new
    s.id = 1
    s.status = "NEW"
    s.save

    s1 = Status.new
    s1.id = 2
    s1.status = "SUBMITTED"
    s1.save

    s2 = Status.new
    s2.id = 3
    s2.status = "APPROVED"
    s2.save

    s3 = Status.new
    s3.id = 4
    s3.status = "REJECTED"
    s3.save

    s4 = Status.new
    s4.id = 5
    s4.status = "EDIT"
    s4.save
  end

  def create_project
    p = Project.new
    p.id = 1
    p.customer_id = 1
    p.name = "Time Entries"
    p.user_id = 1
    p.save
  end

  def create_adhoc_pm
    p = Project.new
    p.id = 2
    p.name = "Time Entries"
    p.user_id = 1
    p.adhoc_pm_id = 1
    p.adhoc_start_date = Time.now.to_s
    p.adhoc_end_date = (Time.now+1.day).to_s
    p.save

  end

  def create_customers
    c = Customer.new
    c.id = 1
    c.user_id = 1
    c.name = "Test"
    c.address = "Test"
    c.city = "Herndon"
    c.zipcode = "20170"
    c.save
  end

  def create_customer_manager
    u = User.new
    u.id = 1
    u.customer_id = 1
    u.first_name = "CM"
    u.last_name = "user"
    u.email = "cm.user@test.com"
    u.password = "123456"
    u.encrypted_password
    u.user = 1
    u.cm = 1
    u.employment_type = 1
    u.save!

    create_task
    create_week
    create_expense_records
    create_status
    create_customers
    create_project
    create_employment_type
    pu1 = ProjectsUser.new
    pu1.project_id = 1
    pu1.user_id =  1
    pu1.save

  end

  def create_project_manager
    create_employment_type
    u = User.new
    u.id = 1
    u.customer_id = 1
    u.first_name = "PM"
    u.last_name = "user"
    u.email = "pm.user@test.com"
    u.password = "123456"
    u.encrypted_password
    u.user = 1
    u.pm = 1
    u.employment_type = 1
    u.save!

    create_task
    create_week
    create_status
    create_customers
    #create_customer_holidays
    create_project
    
  end

  def create_holidays
    h = Holiday.new
    h.id = 1
    h.name = "labor day"
    h.date = "2017-08-04"
    h.global = 1
    h.save
  end

  def create_expense_records
    ex = ExpenseRecord.new
    ex.id = 1
    ex.expense_type = "Travel"
    ex.project_id = 1
    ex.week_id = 3
    ex.save
  end

  def create_customer_holidays
    create_holidays
    ch = CustomerHoliday.new
    ch.customer_id = 1
    ch.holiday_id = 1
    ch.save
  end

  def create_user
    u = User.new
    u.id = 1
    u.email = "test.user1@test.com"
    u.password = "1234567"
    u.encrypted_password
    u.user = 1
    u.employment_type = 1


    u.save!
    create_customers
    create_employment_type
    create_task
    create_status
    create_week
    
    #create_second_week
    # t = Task.new
    # t.code = "007"
    # t.description = "Test Description"
    # # t.project_id = 1
    # t.save!

    # w = Week.new
    # w.id = 1
    # w.save
   
    #create_status

    u1 = User.new
    u1.id = 2
    u1.email = "pm.user@test.com"
    u1.password = "123456"
    u1.encrypted_password
    u1.user = 1
    u1.pm = 1
    u1.customer_id = 1
    u1.save!

     p = Project.new
     p.id = 1
     p.name = "Time Entries"
     p.user_id = 2
     p.customer_id = 1
     p.save

     create_projects_user



  end

  def create_projects_user
    pu1 = ProjectsUser.new
    pu1.project_id = 1
    pu1.user_id =  1
    pu1.save

    pu2 = ProjectsUser.new
    pu2.project_id = 1
    pu2.user_id =  2
    pu2.save
  end

  def status
    s = Status.new
    if s.id == 1
      s.status = "NEW"
    elsif s.id == 2
      s.status = "SUBMITTED"
    end

    s.save
  end
end

World(TestDataSetupHelper)

# Before do
#
#
#   def create_user
#     u = User.new
#     u.id = 1
#     u.email = "test.user@test.com"
#     u.password = "123456"
#     u.encrypted_password
#     u.user = 1
#     # u.admin = 1
#     u.pm = 1
#     # u.cm = 1
#
#     u.save!
#     u
#   end
#   def create_task
#     t = Task.new
#     t.code = "007"
#     t.description = "Test Description"
#     # t.project_id = 1
#     t.save!
#   end
#
#   def create_customer
#     c = Customer.new
#     c.id =  1
#     c.name = "Test"
#     c.address = "21 Jump Stree"
#     c.city = "test"
#     c.state = "CA"
#     c.zipcode = "000"
#     # c.user_id = 1
#     c.save!
#   end
#
#   def create_project
#     p = Project.new
#     p.id = 1
#     p.name = "Time Entries"
#     p.user_id = 1
#     p.save!
#     p
#   end
#   def create_week
#     w = Week.new
#     w.id = 1
#     w.save
#   end
#
#   def create_projects_users
#     ps = ProjectsUser.new
#     ps.project_id = 1
#     ps.user_id = 1
#   end
#
#   def create_status
#     s = Status.new
#     s.id = 1
#     s.status = "NEW"
#     s.save
#   end
#
#   user = create_user
#   create_task
#   create_customer
#   project = create_project
#   user.projects << project
#   # create_status
#   visit (new_user_session_path)
#   page.fill_in "Email", :with => "test.user@test.com"
#   page.fill_in "Password", :with => "123456"
#   page.click_button "Log in"
# end

