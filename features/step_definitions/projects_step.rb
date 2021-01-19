#
# # Given(/^I logged in$/) do
# #   visit (weeks_path)
# # end
# #
# # Then(/^Link to "([^"]*)" should be present$/) do |arg1|
# #   expect(page).to have_link(arg1, href: 'projects')
# # end
#
#
#
# Given(/^I am on the projects page$/) do
#   visit (projects_path)
# end
#
# Then(/^I should be seeing "([^"]*)"$/) do |arg|
#   page.should have_content(arg)
# end
#
# Given(/^I am on project edit page$/) do
#   visit ("/projects/1/edit")
# end
#
# Then(/^I should see "([^"]*)"$/) do |heading|
#   page.should have_content(heading)
# end
#
# Then(/^I fill in "([^"]*)" with "([^"]*)"$/) do |arg1, email|
#   fill_in 'user_email', :with => email
# end
#
# # Then(/^I click "([^"]*)"$/) do |invite|
# #   page.click_button invite
# #   open_email 'test1@gmail.com'
# # end
#
# Then(/^I click "([^"]*)" having email "([^"]*)"$/) do |invite_button, email|
#   page.click_button invite_button
#   open_email email
# end
#
#
# Then(/^I should see Invitation subject "([^"]*)"$/) do |invitation_subject|
#   expect(current_email.subject).to eq invitation_subject
# end
#
# Then(/^I click on "([^"]*)"$/) do |arg1|
#   current_email.click_link 'Accept invitation'
# end
#
# Then(/^I should have heading "([^"]*)"$/) do |arg1|
#   page.should have_content 'Create an Account'
#   clear_emails
# end
#
# Then(/^I fill "([^"]*)" with "([^"]*)"$/) do |arg1, arg2|
#   page.fill_in "First name", :with => "Ace"
#   page.fill_in "Last name", :with => "Mccloud"
#   # check('#user_google_account')
#   # find(:css, "#user_google_account").set(true)
#   page.fill_in "Password", :with => "123456"
#   page.fill_in "Password confirmation", :with => "123456"
# end
#
# Then(/^Clink "([^"]*)"$/) do |create_account|
#   page.click_button create_account
# end
#
# Then(/^"([^"]*)" should be visible$/) do |enter_and_manage_time|
#   page.should have_content enter_and_manage_time
#   expect(page).to have_link('Enter Time for Current Week', href: '/weeks/new')
#   expect(page).to have_no_link('Manage Projects', href: 'projects')
# end
#
#
# Then(/^Check Sign in with Google$/) do
#   find(:css, "#user_google_account").set(true)
# end
#
# Then(/^I should go to the google page$/) do
#   visit (user_google_oauth2_omniauth_authorize_path)
# end
#
#
# Then(/^You should not see Sign in with Google$/) do
#   page.should have_no_content("Sign in with Google")
# end
