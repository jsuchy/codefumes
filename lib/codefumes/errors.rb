module CodeFumes
  module Errors #:nodoc:
    class InsufficientCredentials < StandardError #:nodoc:
    end

    class UnsupportedScmToolError < StandardError #:nodoc:
    end

    class UnknownProjectError < StandardError #:nodoc:
    end

    class NoUserApiKeyError < ArgumentError #:nodoc:
    end
  end
end
