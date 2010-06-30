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

      build = Build.new(:public_key => public_key,
                        :private_key => private_key,
                        :commit_identifier => commit_identifier,
                        :name => build_name,
                        :state => "running",
                        :started_at => started_at,
                        :ended_at   => "")
      build.save
    end

    def self.finish(build_name, success_or_failure, options = {})
      repo = SourceControl.new(options[:repository_path] || './')

      commit_identifier = options[:commit_identifier] || repo.local_commit_identifier
      public_key        = options[:public_key]  || repo.public_key
      private_key       = options[:private_key] || repo.private_key
      ended_at          = options[:ended_at]  || Time.now

      build = Build.find(:public_key => public_key,
                         :private_key => private_key,
                         :commit_identifier => commit_identifier,
                         :identifier => build_name
                        )
      return false if build.nil?
      build.state = success_or_failure.to_s
      build.ended_at = ended_at
      build.save
    end
  end
end
