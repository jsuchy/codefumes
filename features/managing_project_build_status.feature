Feature: Managing a project's build status
  Tracking the build status of a project is one of, if not
  THE primary purpose of CodeFumes.com. As the owner of a project
  I want to be able to easily manage and the state of an read
  the state of various builds for a project.

  Scenario: Starting a build for a project
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    When I run "#{@bin_path}/fumes build --start ie7"
    Then the output should contain "Setting 'ie7' build status to 'started'"
    And the output should contain "'ie7' build successfully marked as 'started'"
    And the exit status should be "SUCCESS"

  Scenario: Setting a project build status to 'failure'
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --start ie7"
    When I run "#{@bin_path}/fumes build --finished=failed ie7"
    Then the output should contain "Setting 'ie7' build status to 'failed'"
    And the output should contain "'ie7' build successfully marked as 'failed'"
    And the exit status should be "SUCCESS"

  Scenario: Setting a project build status to an invalid state
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --start ie7"
    When I run "#{@bin_path}/fumes build --finished=badstate ie7"
    Then the output should contain "Invalid build state"
    And the exit status should be "INVALID_BUILD_STATE"

  Scenario: Attempting to set multiple build states in same command
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --start ie7"
    When I run "#{@bin_path}/fumes build --finished=failed --start ie7"
    Then the output should contain "multiple states"
    And the exit status should be "INVALID_COMMAND_SYNTAX"

  Scenario: Retrieving the current build state of a specific build
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --start ie7"
    When I run "#{@bin_path}/fumes build --status ie7"
    Then the output should contain "running"
    And the exit status should be "SUCCESS"
