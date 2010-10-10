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
    And the exit status should be "SUCCESS"

  Scenario: Setting a project build status to 'failure'
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --start ie7"
    When I run "#{@bin_path}/fumes build --finished=failed ie7"
    Then the output should contain "Setting 'ie7' build status to 'failed'"
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

  Scenario: Retrieving the current build state of a all builds of the latest commit
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --start ie7"
    And I run "#{@bin_path}/fumes build --start specs"
    When I run "#{@bin_path}/fumes build --status --all"
    Then the output should contain 2 running build status messages
    And the exit status should be "SUCCESS"

  Scenario: Running the build command without any arguments
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    When I run "#{@bin_path}/fumes build"
    Then the output should contain "build [options]"
    Then the output should contain "Options:"
    And the exit status should be "INVALID_COMMAND_SYNTAX"

  Scenario: Wrapping a successful build command with build start & stop information
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --exec='ls ./' ie7"
    Then the output should contain "Executing: 'ls ./'"
    And the output should contain "Setting 'ie7' build status to 'started'"
    And the exit status should be "SUCCESS"

  Scenario: Wrapping a failing build command with build start & stop information
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --exec='lr ./' ie7"
    Then the output should contain "Executing: 'lr ./'"
    And the output should contain "Setting 'ie7' build status to 'started'"
    And the exit status should be "STANDARD_BUILD_FAILURE"

  Scenario: Specifying --start AND --exec in the same command
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --start --exec='lr ./' ie7"
    Then the output should contain "'--exec' and the '--start' flags"
    And the output should not contain "Executing: 'lr ./'"
    And the output should not contain "Setting 'ie7' build status to 'started'"
    And the exit status should be "INVALID_COMMAND_SYNTAX"

  Scenario: Specifying --finished AND --exec in the same command
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes build --finished='failed' --exec='lr ./' ie7"
    Then the output should contain "'--exec' and the '--finished' flags"
    And the output should not contain "Executing: 'lr ./'"
    And the output should not contain "Setting 'ie7' build status to 'started'"
    And the exit status should be "INVALID_COMMAND_SYNTAX"

  Scenario: Starting a build for a project without specifying a build name
    Given I have cloned and synchronized 1 project
    And I cd to "project_1/"
    When I run "#{@bin_path}/fumes build --start"
    Then the output should contain "include a build name"
    And the output should not contain "build status to 'started'"
    And the exit status should be "INVALID_COMMAND_SYNTAX"
