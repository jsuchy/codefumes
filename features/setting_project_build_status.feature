Feature: Setting a project's build status
  Tracking the build status of a project is one of, if not
  THE primary purpose of CodeFumes.com. As the owner of a project
  I want to be able to easily manage and the state of an read
  the state of various builds for a project.

  Scenario: Starting a build for a project
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    When I run "#{@bin_path}/fumes build --start ie7"
    Then the output should contain "Attempting to start 'ie7' build"
    And the output should contain "'ie7' build successfully marked as 'started'"
    And the exit status should be 0
