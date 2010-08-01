module CodeFumes
  module Errors #:nodoc:
    class InsufficientCredentials < StandardError #:nodoc:
    end

    class UnsupportedScmToolError < StandardError #:nodoc:
    end

    class UnknownProjectError < StandardError #:nodoc:
    end
  end
end
