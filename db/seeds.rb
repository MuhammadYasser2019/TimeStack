# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Status.find_or_initialize_by(id: 1, status: 'NEW') do |s|
  s.save!
end
Status.find_or_initialize_by(id: 2, status: 'SUBMITTED') do |s|
  s.save!
end
Status.find_or_initialize_by(id: 3, status: 'APPROVED') do |s|
  s.save!
end
Status.find_or_initialize_by(id: 4, status: 'REJECTED') do |s|
  s.save!
end
Status.find_or_initialize_by(id: 5, status: 'EDIT') do |s|
  s.save!
end

Role.find_or_initialize_by(id: 1, name: "User") do |n|
  n.save!
end
Role.find_or_initialize_by(id: 2, name: "CustomerManager") do |n|
  n.save!
end
Role.find_or_initialize_by(id: 3, name: "ProjectManager") do |n|
  n.save!
end
Role.find_or_initialize_by(id: 4, name: "Admin") do |n|
  n.save!
end

Shift.find_or_initialize_by(id: 1, name: "Regular") do |n|
  n.start_time = "9:00AM"
  n.end_time = "5:00PM"
  n.regular_hours = 8
  n.incharge = nil
  n.active = true
  n.default = true
  n.location = nil
  n.capacity = nil
  n.save!
end

weeks_with_no_status = TimeEntry.where(status_id: nil).select(:week_id).collect { |w| w.week_id }.uniq

weeks_with_no_status.each do |w_id|
  if !w_id.nil?
    TimeEntry.where(week_id: w_id).each do |te|
      te.status_id 	= Week.find(w_id).status_id
      te.approved_by 	= Week.find(w_id).approved_by
      te.approved_date 	= Week.find(w_id).approved_date
      te.save!
    end
  end
end
Feature.find_or_initialize_by(id: 1, feature_type: "Easy Automation") do |f|
 f.save!
end
Feature.find_or_initialize_by(id: 2, feature_type: "Employee Time Entry") do |f|
 f.save!
end
Feature.find_or_initialize_by(id: 3, feature_type: "Submission and Approval") do |f|
 f.save!
end
Feature.find_or_initialize_by(id: 4, feature_type: "Flexible Reports") do |f|
 f.save!
end
Feature.find_or_initialize_by(id: 5, feature_type: "Optional Payroll System Integration") do |f|
 f.save!
end
Feature.find_or_initialize_by(id: 6, feature_type: "Resourse Stack") do |f|
 f.save!
end
Feature.find_or_initialize_by(id: 7, feature_type: "JSM Consulting") do |f|
 f.save!
end
Feature.find_or_initialize_by(id: 8, feature_type: "About") do |f|
 f.save!
end
Feature.find_or_initialize_by(id: 9, feature_type: "Company Overview") do |f|
 f.save!
end

Feature.find_or_initialize_by(id: 10, feature_type: "FAQ for Project Manager") do |f|
  f.save!
end

Feature.find_or_initialize_by(id: 11, feature_type: "FAQ for Customer Manager") do |f|
  f.save!
end

Feature.find_or_initialize_by(id: 12, feature_type: "FAQ for User") do |f|
  f.save!
end

User.find_or_initialize_by(email: 'technicalsupport@resourcestack.com') do |f|
  f.first_name = "Technical"
  f.last_name = "Support"
  f.user = true
  f.cm = true
  f.admin =true
  f.password= 'pass@123'
  f.encrypted_password
  f.save
end

Customer.find_or_initialize_by(name: 'Chronstack') do |c|
  c.zipcode = '20170'
  c.user_id = User.find_by(email: 'technicalsupport@resourcestack.com').id
  c.save
end