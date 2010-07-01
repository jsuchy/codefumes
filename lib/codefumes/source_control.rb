module CodeFumes
  # Defines the contract between CodeFumes and any local source control
  # management system (SCM).
  #
  # *NOTE:* Git is currently the only supported SCM. We look
  # forward to changing this soon.
  class SourceControl
    SUPPORTED_SCMS_AND_DETECTORS = {:git => '.git'} #:nodoc:

    # Sets up a SourceControl object to read content from the repository
    # located at +path+.
    def initialize(path)
      begin
        @repository = Grit::Repo.new(path)
      rescue Grit::InvalidGitRepositoryError
        raise Errors::UnsupportedScmToolError
      end
    end

    # Returns a serialized Hash containing a single +:commits+ key
    # associated with an Array of serialized commit information, ready
    # to be sent to the CodeFumes service.
    def payload_between(from = initial_commit_identifier, to = "HEAD")
      start_commit = from || initial_commit_identifier
      end_commit = to || "HEAD"
      new_commits = commits_between(start_commit, end_commit)
      new_commits.empty? ? {} : {:commits => new_commits}
    end
    alias :payload :payload_between

    # Returns the first commit identifier of a repository's history.
    def initial_commit_identifier
      initial_commit.sha
    end

    # Returns an array of 'symbolized' executable names for all
    # supported SCMs.
    #
    # The names are returned as symbols.
    def self.supported_systems
      SUPPORTED_SCMS_AND_DETECTORS.keys
    end

    # Accepts command-line executable name of SCM and returns whether it
    # is a supported SCM or not. +tool_cli_name+ should be the
    # name of the executable, not the 'full name' of the application
    # (ex: 'svn' not 'subversion').
    #
    # Returns +true+ if the SCM is supported
    #
    # Returns +false+ if the SCM is not supported.
    def self.supported_system?(tool_cli_name)
      SUPPORTED_SCMS_AND_DETECTORS.keys.include?(tool_cli_name.to_sym)
    end

    # Stores the public_key of the project associated with the
    # underlying local repository.  This will not be necessary
    # with all SCMs.
    #
    # For example, in a git repository, this method will store a
    # +codefumes+ key in the +.git/config+ file.  This value can be used
    # as a lookup key for other tools to use in conjunction with the
    # CodeFumes config file (see +ConfigFile+) to interact with a
    # CodeFumes project.
    def store_public_key(public_key)
      @repository.config["codefumes.public-key"] = public_key
    end

    # Removes any association to the CodeFumes service which would have
    # been added using the +store_public_key+ method.
    #
    # This method does not remove anything from the user's global
    # CodeFumes config file.
    def unlink_from_codefumes!
      @repository.git.config({}, "--remove-section", "codefumes")
    end

    # Returns the public key of the project associated with this
    # repository.
    def public_key
      @repository.config["codefumes.public-key"]
    end

    # Returns the private key of the project assciated with this
    # repository.
    def private_key
      ConfigFile.options_for_project(public_key)[:private_key]
    end

    # Returns the current commit identifier of the underlying
    # repository ('HEAD' of the supplied branch in git parlance).
    def local_commit_identifier(branch_name = "master")
      raise ArgumentError, "nil branch name supplied" if branch_name.nil?
      @repository.get_head(branch_name).commit.sha
    end

    # Returns the full path of the underlying repository.
    def path
      @repository.path
    end

    private
      def initial_commit
        @repository.log.last
      end

      # Returns Array of serialized commit data. Each item in the Array
      # contains attributes of a single commit.
      def commits_between(from, to, including_from_commit = false)
        commit_list = @repository.commits_between(from,to)

        if including_from_commit == true || from == initial_commit_identifier
          commit_list = [initial_commit] + commit_list
        end

        commit_list.map do |commit|
          commit_stats = commit.stats
          {
            :identifier => commit.sha,
            :author_name => commit.author.name,
            :author_email => commit.author.email,
            :committer_name => commit.committer.name,
            :committer_email => commit.committer.email,
            :authored_at => commit.authored_date,
            :committed_at => commit.committed_date,
            :message => commit.message,
            :short_message => commit.short_message,
            :parent_identifiers => commit.parents.map(&:sha).join(','),
            :line_additions => commit_stats.additions,
            :line_deletions => commit_stats.deletions,
            :line_total => commit_stats.deletions,
            :affected_file_count => commit_stats.files.count
          }
        end.reverse
      end
  end
end
