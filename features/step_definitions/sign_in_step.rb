# Given(/^I am on the sign in page$/) do
#   visit (new_user_session_path)
# end
#
# Then(/^I should see "([^"]*)"$/) do |arg1|
#   page.should have_content arg1
# end
#
# Then(/^I should not see "([^"]*)"$/) do |arg2|
#   page.should have_no_content arg2
# end
#
#
# When(/^I fill in "([^"]*)" with "([^"]*)"$/) do |email, pass|
#   page.fill_in "Email", :with => email
#   page.fill_in "Password", :with => pass
# end
#
# When(/^I click "([^"]*)" button$/) do |login|
#   page.click_button login
# end
#
# Then(/^I should find "([^"]*)"$/) do |ent|
#   page.should have_no_content ent
# end

# Given(/^I am a normal user$/) do
#   create_user
# end