module CodeFumes
  module Errors #:nodoc:
    class InsufficientCredentials < StandardError #:nodoc:
    end

    class UnsupportedScmToolError < StandardError #:nodoc:
    end

    class UnknownProjectError < StandardError #:nodoc:
    end

    class InvalidCommandSyntax < StandardError #:nodoc:
    end

    class NoUserApiKeyError < ArgumentError #:nodoc:
    end

    class NoApiKeySpecified < ArgumentError #:nodoc:
    end

    class InvalidBuildState < ArgumentError #:nodoc:
    end

    class MissingLaunchyGem < Gem::LoadError #:nodoc:
    end
  end
end
