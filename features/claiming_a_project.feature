Feature: Claiming a project
  As the owner of a project, if I have decided I want to use the CodeFumes
  service, I don't want to have to remember the public key for my project(s).
  The gem must provide a simple method of "claiming" a project and associating
  it with an account.


  Scenario: Specified project does not exist on CodeFumes.com
    Given valid user credentials have been stored in the CodeFumes config file
    When I run "#{@bin_path}/fumes claim -p bad-public-key"
    Then the output should contain "Not Found"
    And the exit status should be "SUCCESS"

  Scenario: Attempting to claim a project without having an API key entry in the CodeFumes config file
    Given I have cloned and synchronized 1 project
    When I claim the project
    Then the output should contain instructions about storing your API key
    And the exit status should be 3

  Scenario: Attempting to claim a project with an invalid API key entry in the user's CodeFumes config file
    Given invalid user credentials have been stored in the CodeFumes config file
    And I have cloned and synchronized 1 project
    When I claim the project
    Then the output should contain "Denied"
    And the exit status should be "SUCCESS"

  Scenario: Claim a project using the key stored in a CodeFumes project directory
    Given valid user credentials have been stored in the CodeFumes config file
    And I have cloned and synchronized 1 project
    When I claim the project
    Then the output should contain "Success"
    And the exit status should be "SUCCESS"

  Scenario: Claiming one of multiple projects in your CodeFumes config file
    Given valid user credentials have been stored in the CodeFumes config file
    And I have cloned and synchronized 2 projects
    When I claim the 1st project
    Then the output should contain 1 successful claim message
    And the exit status should be "SUCCESS"

  Scenario: Claim all projects in your CodeFumes config file
    Given valid user credentials have been stored in the CodeFumes config file
    And I have cloned and synchronized 2 projects
    And I run "#{@bin_path}/fumes claim -a"
    Then the output should contain 2 successful claim messages
    And the exit status should be "SUCCESS"
