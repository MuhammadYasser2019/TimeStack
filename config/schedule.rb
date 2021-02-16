require File.expand_path(File.dirname(__FILE__) + "/environment")

set :output, "#{Rails.root}/log/cron_log.log"

set :environment, "development"
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every :monday, :at => "12:01 am" do
  Rails.logger.debug "SUNDAY SUNDAY SUNDAY"
  runner "Week.weekly_weeks"
end

every 15.minute do
  runner "UserDevice.send_shift_notification"
end

every :friday, :at => "11:59 pm" do
  Rails.logger.debug "FRIDAY FRIDAY FRIDAY"
  runner "Week.weekly_time_entry_submit"
end

# every 45.minute do
#   runner "User.reset_token"
# end

every 1.day do
  runner "User.send_password_reminder_email"
  runner "User.update_shift_request"
end