Feature: Claiming a project
  As the owner of a project, if I have decided I want to use the CodeFumes
  service, I don't want to have to remember the public key for my project(s).
  The gem must provide a simple method of "claiming" a project and associating
  it with an account.


  Scenario: Specified project does not exist on CodeFumes.com
    Given valid user credentials have been stored in the CodeFumes config file
    When I run "#{@bin_path}/fumes claim -p bad-public-key"
    Then the output should contain "Not Found"
    And the exit status should be 0

  Scenario: Attempting to claim a project without having an API key entry in the CodeFumes config file
    Given I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    When I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim"
    Then the output should contain "fumes setup"
    And the exit status should be 3

  Scenario: Attempting to claim a project an invalid API key entry in the user's CodeFumes config file
    Given invalid user credentials have been stored in the CodeFumes config file
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    When I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim"
    Then the output should contain "Denied"
    And the exit status should be 0

  Scenario: Claim a project using the key stored in a CodeFumes project directory
    Given valid user credentials have been stored in the CodeFumes config file
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    When I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim"
    Then the output should contain "Success"
    And the exit status should be 0

  Scenario: Claiming one of multiple projects in your CodeFumes config file
    Given valid user credentials have been stored in the CodeFumes config file
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git project_1"
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git project_2"
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes sync"
    And I cd to "../project_2/"
    And I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim"
    Then the output should contain 1 successful claim
    And the exit status should be 0

  Scenario: Claim all projects in your CodeFumes config file
    Given valid user credentials have been stored in the CodeFumes config file
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git project_1"
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git project_2"
    And I cd to "project_1/"
    And I run "#{@bin_path}/fumes sync"
    And I cd to "../project_2/"
    And I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim -a"
    Then the output should contain 2 successful claims
    And the exit status should be 0
