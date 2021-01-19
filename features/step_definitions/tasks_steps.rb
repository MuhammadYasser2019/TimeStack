# Given(/^I am on the tasks page$/) do
#   visit (tasks_path)
# end
#
# Then(/^I should see "([^"]*)" in the selector "([^"]*)"$/) do |text, selector|
#   page.first(selector).text.should == text
# end
#
# Then(/^I should see "([^"]*)" and "([^"]*)" and "([^"]*)" on selector "([^"]*)"$/) do |code, description, project, th|
#   page.first('table thead tr th[1]').text.should == code
#   page.first('table thead tr th[2]').text.should == description
#   page.first('table thead tr th[3]').text.should == project
# end
#
# Then(/^when you click on "([^"]*)" you should be redirected to "([^"]*)"$/) do |edit, arg2|
#   page.click_link(edit)
#   # expect(current_path).to eql("/tasks/8/edit")
# end
=begin
#create_user
 #visit (user_session_path)
  #page.fill_in "Email", :with => "test.user1@test.com"
  #page.fill_in "Password", :with => "1234567"
  #page.click_button "Log in"

  expect(page).to have_link("Enter Time for Current Week", href: '/weeks/new')
  visit (weeks_path)
  page.click_on "Enter Time for Current Week"

   page.should have_content('New week')

   find('#week_time_entries_attributes_0_project_id').find(:xpath, 'option[1]').select_option
=end
