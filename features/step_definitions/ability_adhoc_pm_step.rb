Given(/^I am a adhoc user$/) do
  create_user
  create_adhoc_pm
end

Given(/^adhoc user logs in with "([^"]*)" and "([^"]*)"$/) do |arg1, arg2|
  visit (user_session_path)
  page.fill_in "Email", :with => "test.user1@test.com"
  page.fill_in "Password", :with => "1234567"
  page.click_button "Log in"
end

Given(/^On the week index page$/) do
  visit (weeks_path)
end

Then(/^user should see link to "([^"]*)" and "([^"]*)"$/) do |arg1, arg2|
  expect(page).to have_link(arg1, href: '/weeks/new')
  expect(page).to have_link(arg2, href: '/projects?adhoc=true')
end

Then(/^user should see link to "([^"]*)"$/) do |arg1|
  expect(page).to have_link(arg1)
end

