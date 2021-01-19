Feature: Testing abilities of a User with CM role

  Scenario: On the weeks index manage project link should be present
    Given I am a customer manager
    Given CM logs in with "Email" and "Password"
    Given On the index page


  Scenario: 3) 6) With CM roles user should be able to submit time sheet and View Project Reports
   Given I am a customer manager
   Given CM logs in with "Email" and "Password"
   Given If "Enter Time for Current Week" is clicked
   Then HE should go to new time entries
   And click "Save Timesheet"
   And Go to the index page
   And Expect page to have "NEW" link
   And click on the "NEW" link
   And Expect page to have link "Save Timesheet" and "Submit Timesheet"
   And click on "Submit Timesheet"
   Then CM should see the entire weeks report and the status as "Status: SUBMITTED"

  Scenario: 9) With CM roles user should be able to Add projects
    Given I am a customer manager
    Given CM logs in with "Email" and "Password"
    Then I should see contentsss and "Pending Users"
    And click on the button "Manage Projects"
    Then User should see heading "Listing projects"
    And CM Expect page to have "plus"
    Then CM clicks on the button "plus"
    Then Expect page to have "New project"
 
  Scenario: 13) 14) 4) With CM roles user should be able to Edit Projects and Add Tasks #####and Approve/Reject timesheets.
    Given I am a customer manager
    Given CM logs in with "Email" and "Password"
    Given User is on Weeks index
    And click on the "Manage Projects"
    Then Should see "Listing projects" 
    And Should be able to see heading "Tasks"
    And Should see "Add Task"
  
  Scenario: With CM roles user should able to make a vacation request
    Given I am a customer manager
    Given CM logs in with "Email" and "Password"
    Given User is on Weeks index
    Then CM Expect page to have "Vacation Request"
    And CM clicks on "Vacation Request" link
    Then User should see "Reports for Users CM user" 
    And User should see "Your Vacation Requests"

  #Scenario: 18) With CM role user should able to create New Holiday
    #Given I am a customer manager
    #Given CM logs in with "Email" and "Password"
    #Given User is on Weeks index
    #And click on "Holidays" link
    #Then click the button "Create New Holiday"
    #And Enter "Name" and "Date of holiday this year"
   
  Scenario: 21) With CM role user should be able to create Employment Types
    Given I am a customer manager
    Given CM logs in with "Email" and "Password"
    Given User is on Weeks index
    Then Click on the "Employment Types"
    And Click on the "Create New Employment Type"
    And Enter a "Name" 
    And page should have a button "Create Employment Type"
    And click button "Create Employment Type"

  Scenario: 26) CM should able to copy the timesheet from previous week and clear,edit the current week
    Given I am a customer manager
    Given CM logs in with "Email" and "Password"
    Given If "Enter Time for Current Week" is clicked
    Then HE should go to new time entries
    And click "Save Timesheet"
    And Go to the index page
    And Expect page to have "NEW" link
    Then user should see the link "COPY"
    Then cm clicks on the link "COPY"
    Then User clicks on the "EDIT" link
    And should see the "8" in "hours" field
    Then user should see the link "CLEAR" for clearing 
    And click on the clear "CLEAR" button
    Then user should see the new link "NEW"
    And click on new "NEW"
    And should see "" in "Hours" 
    And should see "" in "Description"
    And Expect page to have add "ADD EXPENSES"
    And Expect page to have text "Travel"
    And Expect page to have delete "Delete" button


  Scenario: 27) When the TimeSheet is submitted, there should be no COPY Link for that week
    Given I am a customer manager
    Given CM logs in with "Email" and "Password"
    And Expect page to have link "SUBMITTED" but not "COPY" link

  Scenario: 28) When it is first TimeSheet, there should be NEW but no COPY link
    Given I am a customer manager
    Given CM logs in with "Email" and "Password"
    Given If "Enter Time for Current Week" is clicked
    Then HE should go to new time entries
    And click "Save Timesheet"
    And Go to the index page
    And Expect page to have link "NEW" but not "COPY"

  Scenario: 29) With CM role user should able to make shared employee and assign PM role
    Given I am a customer manager
    Given CM logs in with "Email" and "Password"
    Given User is on customers index
    Then page should have "Customer Employees" link
    Then click on "Customer Employees" link
    Then Expect page to have change share status "Change Share Status"
    And click on the button change share status "Change Share Status"
    #Then Expect modal window has content "CUSTOMERS LIST"
    #Then click on the shared checkbox
    #Then go to customer index page
    #Then the shared checkbox should be checked

  Scenario: 30) With CM role user should able to add Expenses
    Given I am a customer manager
    Given page to have signin "Deploy in Minutes"
    Given click on signin "Sign In"
    Given CM logs in with "Email" and "Password"
    Given If "Enter Time for Current Week" is clicked
    Then HE should go to new time entries
    And click "Save Timesheet"
    And Go to the index page
    Then User clicks on the new "NEW" link
    And Expect page to have add "ADD EXPENSES"
    Then click on add expenses "ADD EXPENSES"
    And Expect page to have add new "Add New Expense"
    #AfterStep('@javascript') do
    #    begin
    #        And I wait for the ajax request to finish
    #    rescue
    #    end
    #end
    And Expect page to have save "Save Expense"
    #Then fill in Expense Type column wih "Travel"
    #And select a date from date dropdown
    #And select a project from project dropdown
    #And click on Save Expense
    #An
    #And Expect page to have delete "Delete" button

  Scenario: 31) With the CM role user should able to create a new Vacation type
    Given I am a customer manager
    Given page to have signin "Deploy in Minutes"
    Given click on signin "Sign In"
    Given expect page to have "LOGIN"
    Given CM logs in with "Email" and "Password"
    When the CM clicks on link "Vacation Types"
    Then expect page to have heading "Assign Employment"
    And click on manage "Manage Vacation Type"
    Then Expect page to have heading vacation "Vacation Type"
    And click on add new vacation "Add New Vacation"
    Then Expect page to have heading create "Create New Vacation Type"
    And fill in "Vacation title" with "vacation days"
    And click on the Active checkbox
    Then click on update vacation "Update Vacation type"
    Then Expect page to have text testing "vacation days"
    When User is on Weeks index
    When the CM clicks on link "Vacation Types"
    And Expect page to have heading assign employment "Assign Employment"
    Then Select "vacation days" from "vacation type".
    And click on the employment type checkbox 
    Then Expect page to have assign "Assign to Employment"
    Then click on assign "Assign to Employment"


  Scenario: 32) With the CM role user should able to see all the timesheets
    Given I am a customer manager
    Given page to have signin "Deploy in Minutes"
    Given click on signin "Sign In"
    Given CM logs in with "Email" and "Password"
    When the CM clicks on old "Show Old Timesheets"
    Then it should redirects to show old timesheets page

 
