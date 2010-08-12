Feature: Claiming a project
  As the owner of a project, if I have decided I want to use the CodeFumes
  service, I don't want to have to remember the public key for my project(s).
  The gem must provide a simple method of "claiming" a project and associating
  it with an account.


  Scenario: Specified project does not exist on CodeFumes.com
    Given valid user credentials have been stored in the CodeFumes config file
    When I run "#{@bin_path}/fumes claim bad-public-key"
    Then it should fail with:
      """
      not found
      """
    And the exit status should be 2

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
    And the exit status should be 4

  Scenario: Claim a project using the key stored in a CodeFumes project directory
    Given valid user credentials have been stored in the CodeFumes config file
    And I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    When I run "#{@bin_path}/fumes sync"
    And I run "#{@bin_path}/fumes claim"
    Then the output should contain "Success"
    And the exit status should be 0
