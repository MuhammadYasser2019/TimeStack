Feature: Testing abilities of a User with PM role

  Scenario: On the weeks index manage project link should be present
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Given On the index page
    #Then I should see link to "Enter Time for Current Week" and "Manage Projects"


  # This scenario will use the step definitions form ablity_user_step.rb
  Scenario: 3) 6) With PM roles user should be able to submit time sheet and View Project Reports
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Given If enter "Enter Time for Current Week" is clicked
    Then HE should go to new time entries
    And click "Save Timesheet"
    And Go to the index page
    And Expect page to have "NEW" link
    And click on the "NEW" link
    And Expect page to have link "Save Timesheet" and "Submit Timesheet"
    And click on "Submit Timesheet"
    Then PM should see the entire weeks report and the status as "Status: SUBMITTED"

  Scenario: 13) 14) 4) With PM roles user should be able to Approve/Reject timesheets.
    Given I am a user
    Given user logs in with "Email" and "Password"
    Given If "Enter Time for Current Week" is clicked
    Then HE should go to new time entries
    And Select "Time Entries" from "project"
    And click "Save Timesheet"
    And Go to the index page
    And Expect page to have "NEW" link
    And click on the "NEW" link
    And Expect page to have link "Save Timesheet" and "Submit Timesheet"
    And click on "Submit Timesheet"
    Then click on logout
    Given PM logs in with "Email" and "Password"
    Given User is on Weeks index
    And he should see Time Sheets Submitted for Approval
    Then User should see "Approve" button
    Then User should see button to "Add Comment to Reject"
    

  Scenario: 10) With PM roles user should be able to Add Tasks
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    And Should be able to see heading "Tasks"
    And Should see "Add Task"
    And Fill the code and description of the task

  Scenario: 12) 15) With PM roles user should not be able to Edit a Customer
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Then Go to customers page
    Then User should see "You are not allowed to access this page."


  Scenario: With Pm roles user should be able to assign adhoc PM
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Then Should see "Listing projects"
    Then User should see label "Adhoc Project Manager"


  Scenario: 19) With PM roles user should able to make a vacation request
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Then On the index page
    Then Should see "Listing projects" 
    And click on the "Vacation Request" button with link "/vacation request"
    Then User should see "Reports for Users PM user" 
    And User should see "Your Vacation Requests"

  Scenario: 20) With PM roles user should be able to make an Holiday Exception
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Then On the index page
    Then Should see "Listing projects" 
    And Expect page to have "Holiday Exceptions"
    And PM click on the "Holiday Exceptions" link
    And Expect page to have "New Holiday Exception"

  Scenario: 23) With PM roles user should able to copy the timesheet from previous week
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Given If "Enter Time for Current Week" is clicked
    Then HE should go to new time entries
    And click "Save Timesheet"
    And Go to the index page
    And Expect page to have "NEW" link
    Then user should see the link "COPY"
    Then pm clicks on the link "COPY"
    Then User clicks on the "EDIT" link
    And should see the "8" in "hours" field
    Then user should see the link "CLEAR" for clearing 
    And click on the clear "CLEAR" button
    Then user should see the new link "NEW"
    And click on new "NEW"
    And should see "" in "Hours" 
    And should see "" in "Description"

  Scenario: 24) When the TimeSheet is submitted, there should be no COPY Link for that week
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    And Expect page to have link "SUBMITTED" but not "COPY" link

  Scenario: 25) When it is first TimeSheet, there should be NEW but no COPY link
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Given If "Enter Time for Current Week" is clicked
    Then HE should go to new time entries
    And click "Save Timesheet"
    And Go to the index page
    And Expect page to have link "NEW" but not "COPY"
   
Scenario: 21) With PM roles user should be able to assign users
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Then On the index page
    Then Should see "Listing projects" 
    And Expect page to have "Users on the Project"
    And PM click on the "Users on the Project" link
    And Expect page to have "Available Users"

Scenario: 33) With PM roles user should able to see all projects
    Given I am a project manager
    Given PM logs in with "Email" and "Password"
    Then On the index page
    Then Should see "Listing projects" 
    Then User should able to see all projects "checkbox"
    When the checkbox is checked, user should able to see the projects with inactive as yes and no 