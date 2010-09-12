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
    And the exit status should be "UNSUPPORTED_SCM"

  Scenario: Successful synchronization
    Given I have cloned 1 project
    When I synchronize the project
    Then the exit status should be "SUCCESS"
    And the output should contain "Successfully saved"
    And the output should contain "Visit http://"

  Scenario: Providing feedback when data is being sent to a non-production server
    Given I have cloned 1 project
    When I synchronize the project
    Then the output should contain "non-production"
    And the output should contain "test.codefumes.com"
    And the exit status should be "SUCCESS"

  Scenario: Specifying a custom, but non-existant public/private key combination
    Given I have cloned 1 project
    And I cd to "project_1/"
    When I run "#{@bin_path}/fumes sync -p non-existant-pubkey -a non-existant-privkey"
    And the exit status should be "PROJECT_NOT_FOUND"
