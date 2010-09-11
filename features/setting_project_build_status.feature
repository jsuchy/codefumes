Feature: Setting a project's build status
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
    And the exit status should be 0

  Scenario: Setting a project build status to 'failure'
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --start ie7"
    When I run "#{@bin_path}/fumes build --finished=failed ie7"
    Then the output should contain "Setting 'ie7' build status to 'failed'"
    And the output should contain "'ie7' build successfully marked as 'failed'"
    And the exit status should be 0

  Scenario: Setting a project build status to an invalid state
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --start ie7"
    When I run "#{@bin_path}/fumes build --finished=badstate ie7"
    Then the output should contain "Invalid build state"
    And the exit status should be 7
