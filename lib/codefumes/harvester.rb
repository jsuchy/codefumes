module CodeFumes
  # Simple class responsible for creating a project on the CodeFumes
  # website, storing project information in the CodeFumes config file,
  # and synchronizing a repository's commit history with CodeFumes.com.
  #
  # NOTE: Technically this can be used by anything (obviously), but it
  # was written with the intention of being used with the
  # +harvest_repo_metrics+ script, and is essentially geared for that
  # scenario.
  class Harvester
    attr_reader :path
    DEFAULT_PATH = './' #:nodoc:

    # Accepts the following options:
    # * +:path+ - the path of the repository to gather information from
    #   (Defaults to './').
    # * +:public_key+ - Sets the public key of the project. This
    #   property will be read from the CodeFumes config file if one
    #   exists for the repository supplied at +:path+.
    # * +:private_key+ - Sets the private key of the project. This
    #   property will be read from the CodeFumes config file if on
    #   exists for the repository supplied at +:path+.
    # * +:name+ - Sets the name of the project on the CodeFumes site
    #
    # Note:
    #   Neither the +public_key+ nor +private_key+ is supported
    #   when creating a new project, but is used when updating an
    #   existing one. This prevents custom public keys from being
    #   created, but allows the user to share the public/private
    #   keys of aproject with other users, or use them on other
    #   machines.
    def initialize(passed_in_options = {})
      options = passed_in_options.dup
      @path = File.expand_path(options.delete(:path) || DEFAULT_PATH)
      @repository = initialize_repository
      options.merge!(:public_key => options[:public_key] || @repository.public_key)
      options.merge!(:private_key => options[:private_key] || @repository.private_key)
      @project = initialize_project(options)
    end

    # Creates or updates a project information on the CodeFumes site,
    # synchronizes the repository's commit history, and prints the
    # results to STDOUT.
    #
    # Returns a Hash containing the keys :successful_count and :total_count
    # if the process succeeded and updates were posted to the server with
    # their associated values.
    #
    # Returns and empty Hash if the local repository is in sync with the
    # server and no updates were posted.
    #
    # Returns +false+ if the process failed.
    def publish_data!
      if @project.save
        store_public_key_in_repository
        update_codefumes_config_file
        generate_and_save_payload || {}
      else
        false
      end
    end

    # Returns the CodeFumes public key of the project that is located
    # at the supplied path.
    def public_key
      @project.public_key
    end

    # Returns the CodeFumes private key of the project that is located
    # at the supplied path.
    def private_key
      @project.private_key
    end

    # Returns the CodeFumes 'short uri' of the project that is located
    # at the supplied path. The 'short uri' is similar to a Tiny URL for
    # a project.
    def short_uri
      @project.short_uri
    end

    private
      def initialize_repository
        SourceControl.new(@path)
      end

      def initialize_project(options = {})
        public_key = options[:public_key]
        options = ConfigFile.options_for_project(public_key).merge(options)
        Project.new(public_key, options)
      end

      def store_public_key_in_repository
        @repository.store_public_key(@project.public_key)
      end

      def update_codefumes_config_file
        ConfigFile.save_project(@project)
      end

      def generate_and_save_payload
        payload = @repository.payload(Commit.latest_identifier(@project), "HEAD")
        if payload.empty?
          nil
        else
          payloads = Payload.prepare(@project, payload)
          successful_requests = payloads.select {|payload| payload.save == true}
          {:successful_count => successful_requests.size, :total_count => payloads.size}
        end
      end
  end
end
