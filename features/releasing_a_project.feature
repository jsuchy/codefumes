Feature: Claiming a project
  As the owner of a project, the process of relinquishing ownership
  of a project must be both available and simple.


  Scenario: Specified project does not exist on CodeFumes.com
    Given valid user credentials have been stored in the CodeFumes config file
    When I run "#{@bin_path}/fumes release -p bad-public-key"
    Then the output should contain "Not Found"
    And the exit status should be 0

  Scenario: Attempting to claim a project without having an API key entry in the CodeFumes config file
    And I have cloned and synchronized 1 project
    And I have claimed the project
    When I release the project
    Then the output should contain instructions about storing your API key
    And the exit status should be 3

  Scenario: Attempting to release a project with an invalid API key entry in the user's CodeFumes config file
    Given invalid user credentials have been stored in the CodeFumes config file
    And I have cloned and synchronized 1 project
    And I have claimed the project
    And invalid user credentials have been stored in the CodeFumes config file
    When I release the project
    Then the output should contain "Denied"
    And the exit status should be 0

  Scenario: Releasing a project using the key stored in a CodeFumes project directory
    Given valid user credentials have been stored in the CodeFumes config file
    And I have cloned and synchronized 1 project
    And I have claimed the project
    When I release the project
    Then the output should contain "Success"
    And the exit status should be 0

  Scenario: Releasing one of multiple projects in your CodeFumes config file
    Given valid user credentials have been stored in the CodeFumes config file
    And I have cloned and synchronized 2 projects
    And I have claimed the 1st project
    When I release the 1st project
    Then the output should contain 1 successful release message
    And the exit status should be 0

  Scenario: Releasing all projects in your CodeFumes config file
    Given valid user credentials have been stored in the CodeFumes config file
    And I have cloned and synchronized 2 projects
    And I run "#{@bin_path}/fumes claim -a"
    When I run "#{@bin_path}/fumes release -a"
    Then the output should contain 2 successful release messages
    And the exit status should be 0
