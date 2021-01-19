#
#  Feature: Project page
#
##    Scenario: When I am on index page
##      Given I logged in
##      Then Link to "Manage Projects" should be present
#
#
#    Scenario: Viewing Time Stack's project page
#      Given I am on the projects page
#      Then I should be seeing "Listing projects"
#
#    Scenario: Sending User Invites
#      Given I am on project edit page
#      Then I should see "Editing project"
#      And I fill in "Email" with "test1@gmail.com"
#      And I click "Invite Users" having email "test1@gmail.com"
#      And I should see Invitation subject "Invitation instructions"
#      And I click on "Accept invitation"
#      And I should have heading "Create an Account"
#      And I fill "First name" with "Ace"
#      And I fill "Last name" with "Mccloud"
#      And I fill "Password" with "123456"
#      And I fill "Password confirmation" with "123456"
#      And Clink "Create Account"
#      And "Enter and Manage Time" should be visible
#
#    Scenario: When user tries to login using google account
#      Given I am on project edit page
#      Then I should see "Editing project"
#      And I fill in "Email" with "test1@gmail.com"
#      And I click "Invite Users" having email "test1@gmail.com"
#      And I should see Invitation subject "Invitation instructions"
#      And I click on "Accept invitation"
#      And I should have heading "Create an Account"
#      And I fill "First name" with "Ace"
#      And I fill "Last name" with "Mccloud"
#      And Check Sign in with Google
#      And Clink "Create Account"
#      And I should go to the google page
#
#
#    Scenario: When the invited email id does is not a google account
#      Given I am on project edit page
#      Then I should see "Editing project"
#      And I fill in "Email" with "test1@resourcestack.com"
#      And I click "Invite Users" having email "test1@resourcestack.com"
##     And I should see Invitation subject "Invitation instructions"
#      And I click on "Accept invitation"
#      And I should have heading "Create an Account"
#      And You should not see Sign in with Google
#
#
