module CodeFumes
  class QuickBuild
    # Creates a new build for the CodeFumes project linked
    # at the specified repository path and associates
    # it with the current local commit identifier
    #
    # Returns +true+ if the request succeeded.
    #
    # Returns +false+ if the request failed.
    def self.start(build_name, options = {})
      repo = SourceControl.new(options[:repository_path] || './')

      commit_identifier = options[:commit_identifier] || repo.local_commit_identifier
      public_key        = options[:public_key]  || repo.public_key
      private_key       = options[:private_key] || repo.private_key
      started_at        = options[:started_at]  || Time.now

      project = Project.new(public_key, private_key)
      commit = Commit.new(project, commit_identifier)
      timestamps = {:started_at => started_at, :ended_at => ""}
      build = Build.new(commit, build_name, :running, timestamps)
      build.save
    end

    def self.finish(build_name, success_or_failure, options = {})
      repo = SourceControl.new(options[:repository_path] || './')

      commit_identifier = options[:commit_identifier] || repo.local_commit_identifier
      public_key        = options[:public_key]  || repo.public_key
      private_key       = options[:private_key] || repo.private_key
      ended_at          = options[:ended_at]  || Time.now

      project = Project.new(public_key, private_key)
      commit = Commit.new(project, commit_identifier)

      build = Build.find(commit, build_name)
      return false if build.nil?
      build.state = success_or_failure.to_s
      build.ended_at = ended_at
      build.save
    end
  end
end
