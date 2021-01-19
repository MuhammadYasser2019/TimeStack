# Instead of loading all of Rails, load the
# particular Rails dependencies we need
require 'rubygems'
require 'mysql2'
require 'active_record'

# This script will create a master spreadsheet from the PHDC application database.
# Whenever you see 'add_row', that's when the data is actually added to the spreadsheet, so it has to be compiled
# beforehand.

# DEPRECATED - Connect to ActiveRecord
ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    database: 'timestack_development_2',
    username: 'root',
    password: 'rsi1111'
)

class User < ActiveRecord::Base
  has_many :projects_users
  has_many :projects , :through => :projects_users
  has_many :roles, :through => :user_roles
  has_many :user_roles
  has_many :holiday_exceptions
  has_many :vacation_requests
  has_many :user_notifications
  has_many :project_shifts, through: :projects_users
end

class ProjectsUser < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :project_shift
end

class ProjectShift < ActiveRecord::Base
  belongs_to :shift
  belongs_to :project
  has_many :time_entries
  has_many :projects_users
  has_many :users, through: :projects_users
end

class Shift < ActiveRecord::Base
  has_many :project_shifts
  has_many :projects, :through => :project_shifts
  belongs_to :customer
end

class Project < ActiveRecord::Base
  belongs_to :customer
  has_many :tasks
  has_many :time_entries
  has_many :projects_users
  has_many :users , :through => :projects_users
  has_many :holiday_exceptions
  has_many :project_shifts
  has_many :shifts, :through => :project_shifts
end

class Customer < ActiveRecord::Base
  has_many :projects
  has_and_belongs_to_many :holidays, join_table: :customers_holidays
  accepts_nested_attributes_for :projects, allow_destroy: true, reject_if: proc { |projects| projects[:name].blank? }
  has_many :vacation_requests
  has_many :employment_types
  has_many :vacation_types
  has_many :external_configurations
  has_one :default_report
  has_many :shifts
end

class TimeEntry < ActiveRecord::Base
  belongs_to :project
  belongs_to :task
  belongs_to :week
  belongs_to :user
  belongs_to :vacation_type
  belongs_to :project_shift
  has_many :archived_time_entry
end

Customer.all.each do |customer|
  puts customer.id
  if customer.shifts.count == 0
    Shift.create(customer_id: customer.id, name: 'Regular') do |n|
      n.start_time = "9:00AM"
      n.end_time = "5:00PM"
      n.regular_hours = customer.regular_hours
      n.incharge = nil
      n.active = true
      n.default = true
      n.location = nil
      n.capacity = nil
      n.save!
    end
  end
  default_shift = customer.shifts.where(name: "Regular").first
  customer.projects.each do |project|
    unless project.project_shifts.present?
      project_shift = ProjectShift.create(project_id: project.id, shift_id: default_shift.id)
      project.projects_users.each do |projects_user|
        unless projects_user.project_shift_id
          projects_user.project_shift_id = project_shift.id
          projects_user.save!
          TimeEntry.where(user_id: projects_user.user_id, project_id: projects_user.project_id, project_shift_id: nil).each do |time_entry|
            time_entry.project_shift_id = project_shift.id
            time_entry.save!
          end
        end
      end
    else
      project.project_shifts.each do |project_shift|
        if project_shift.shift.name == "Regular"
          project.projects_users.where(project_shift_id: nil).each do |projects_user|
            projects_user.project_shift_id = project_shift.id
            projects_user.save!
            TimeEntry.where(user_id: projects_user.user_id, project_id: projects_user.project_id, project_shift_id: nil).each do |time_entry|
              time_entry.project_shift_id = project_shift.id
              time_entry.save!
            end
          end
        end
      end
    end
  end
end

TimeEntry.where(project_shift_id: nil).each do |time_entry|
  project_shifts = ProjectShift.where(project_id: time_entry.project_id)
  project_shifts.each do |project_shift|
    if project_shift.shift.name == 'Regular'
      time_entry.project_shift_id = project_shift.id
      time_entry.save!
    end
  end
end
