class AddDefaultProjectShifts < ActiveRecord::Migration[5.2]

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
end
