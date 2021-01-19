Feature: Testing abilities of a User with Adhoc PM role

Scenario: With Adhoc PM roles user should be able to adhoc pm link
    Given I am a adhoc user
    Given adhoc user logs in with "Email" and "Password"
    Given On the week index page
    Then user should see link to "Enter Time for Current Week" 
   
