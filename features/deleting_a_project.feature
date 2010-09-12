Feature: Deleting a project
  The process of deleting a project must be both
  available and simple in order to reduce the number
  of barriers to testing out the service.


  Scenario: The specified project does not exist on CodeFumes.com
    When I run "#{@bin_path}/fumes delete -p bad-public-key"
    Then the output should contain "Not Found"
    And the exit status should be "SUCCESS"

  Scenario: Attempting to delete a project without having an API key entry in the CodeFumes config file
    Given I have cloned and synchronized 1 project
    And I have claimed the project
    When I delete the project
    Then the output should contain 1 successful delete messages
    And the exit status should be "SUCCESS"

  Scenario: Deleting one of multiple projects in your CodeFumes config file
    Given I have cloned and synchronized 2 projects
    And I have claimed the 1st project
    When I delete the 1st project
    Then the output should contain 1 successful delete messages
    And the exit status should be "SUCCESS"

  Scenario: Releasing all projects in your CodeFumes config file
    Given valid user credentials have been stored in the CodeFumes config file
    And I have cloned and synchronized 2 projects
    And I run "#{@bin_path}/fumes claim -a"
    When I run "#{@bin_path}/fumes delete -a"
    Then the output should contain 2 successful delete messages
    And the exit status should be "SUCCESS"
