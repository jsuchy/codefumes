Feature: Claiming a project
  As the owner of a project, the process of relinquishing ownership
  of a project must be both available and simple.


  Scenario: Specified project does not exist on CodeFumes.com
    Given valid user credentials have been stored in the CodeFumes config file
    When I run "#{@bin_path}/fumes release -p bad-public-key"
    Then the output should contain "Not Found"
    And the exit status should be 0

  Scenario: Attempting to claim a project without having an API key entry in the CodeFumes config file
    Given I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    And I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim"
    When I run "#{@bin_path}/fumes release"
    Then the output should contain instructions about storing your API key
    And the exit status should be 3

  Scenario: Attempting to release a project with an invalid API key entry in the user's CodeFumes config file
    Given invalid user credentials have been stored in the CodeFumes config file
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    And I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim"
    And invalid user credentials have been stored in the CodeFumes config file
    When I run "#{@bin_path}/fumes release"
    Then the output should contain "Denied"
    And the exit status should be 0

  Scenario: Releasing a project using the key stored in a CodeFumes project directory
    Given valid user credentials have been stored in the CodeFumes config file
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    And I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim"
    When I run "#{@bin_path}/fumes release"
    Then the output should contain "Success"
    And the exit status should be 0

  Scenario: Releasing one of multiple projects in your CodeFumes config file
    Given valid user credentials have been stored in the CodeFumes config file
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git project_1"
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git project_2"
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes sync"
    And I cd to "../project_2/"
    And I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim"
    When I run "#{@bin_path}/fumes release"
    Then the output should contain 1 successful release message
    And the exit status should be 0

  Scenario: Releasing all projects in your CodeFumes config file
    Given valid user credentials have been stored in the CodeFumes config file
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git project_1"
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git project_2"
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes sync"
    And I cd to "../project_2/"
    And I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim -a"
    When I run "#{@bin_path}/fumes release -a"
    Then the output should contain 2 successful release messages
    And the exit status should be 0
