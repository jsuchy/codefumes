module CodeFumes
  module ExitCodes
    SUCCESS                    = 0
    UNSUPPORTED_SCM            = 1
    PROJECT_NOT_FOUND          = 2
    NO_USER_CREDENTIALS        = 3
    INCORRECT_USER_CREDENTIALS = 4
    NO_API_KEY_SPECIFIED       = 5
    MISSING_DEPENDENCY         = 6
    INVALID_BUILD_STATE        = 7
    INVALID_COMMAND_SYNTAX     = 8
    STANDARD_BUILD_FAILURE     = 9
    UNKNOWN                    = 100
  end
end
