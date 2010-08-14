Feature: Storing a User's API key
  Adding an API key to a user's CodeFumes config file allows
  them to perform actions which require user-authentication,
  such as associating a project with an account.


  Scenario: Issuing 'api-key' without an argument
    When I run "#{@bin_path}/fumes api-key"
    Then it should fail with:
      """
      No API key specified
      """
    And the exit status should be 5

  Scenario: Issuing 'api-key' with an argument
    When I run "#{@bin_path}/fumes api-key userkey"
    Then it should pass with:
      """
      Your API key has been saved to your CodeFumes config file
      """
    And the API key in the config file should be "userkey"
    And the exit status should be 0

  Scenario: Issuing 'api-key' with the --clear flag
    When I run "#{@bin_path}/fumes api-key --clear"
    Then it should pass with:
      """
      Your API key has been removed from your CodeFumes config file
      """
    And the API key in the config file should be cleared
    And the exit status should be 0

  Scenario: Issuing 'api-key' with the --clear flag and an argument
    When I run "#{@bin_path}/fumes api-key userkey1"
    And I run "#{@bin_path}/fumes api-key --clear userkey2"
    Then it should pass with:
      """
      Your API key has been removed from your CodeFumes config file
      """
    And the API key in the config file should be cleared
    And the exit status should be 0
