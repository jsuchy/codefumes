Feature: Synchronizing a repository with CodeFumes
  Keeping a CodeFumes project synchronized with a project's development
  is a fundamental feature of the site/service.  Synchronizing this data must
  be as simple, quick, and reliable as possible in order to provide value to
  the users of the site.

  Scenario: Unsupported repository type
    When I run "#{Dir.pwd}/bin/fumes sync"
    Then it should fail with:
      """
      Unsupported
      """
    And the exit status should be 1

  @announce-stdout @announce-stderr
  Scenario: Successful synchronization
    Given I run "git clone git@github.com:cosyn/git_fixture_repository.git"
    And I cd to "git_fixture_repository/"
    When I run "#{Dir.pwd}/bin/fumes sync"
    Then the exit status should be 0
