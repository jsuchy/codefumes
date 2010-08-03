Feature: Synchronizing a repository with CodeFumes
  Keeping a CodeFumes project synchronized with a project's development
  is a fundamental feature of the site/service.  Synchronizing this data must
  be as simple, quick, and reliable as possible in order to provide value to
  the users of the site.

  Scenario: Unsupported repository type
    When I run "#{@bin_path}/fumes sync"
    Then it should fail with:
      """
      Unsupported
      """
    And the exit status should be 1

  Scenario: Successful synchronization
    Given I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    When I run "#{@bin_path}/fumes sync"
    Then the exit status should be 0
    And the output should contain "Successfully saved"
    And the output should contain "Visit http://"

  Scenario: Providing feedback when data is being sent to a non-production server
    Given I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    When I run "#{@bin_path}/fumes sync"
    Then the output should contain "non-production"
    And the output should contain "test.codefumes.com"
    And the exit status should be 0

  Scenario: Specifying a custom, but non-existant public/private key combination
    Given I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    When I run "#{@bin_path}/fumes sync -p non-existant-pubkey -a non-existant-privkey"
    And the exit status should be 2
