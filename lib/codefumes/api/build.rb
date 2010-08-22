module CodeFumes
  module API
    # Represents a specific instance of tests running on
    # a continuous integration server.  Builds have a name and are
    # associated with # a specific Commit of a Project and can track
    # the current status (running, failed, success) and the
    # start & end times of the Build process.
    class Build
      attr_reader   :created_at, :api_uri, :identifier, :commit, :project
      attr_accessor :started_at, :ended_at, :state, :name

      # Initializes new instance of a Build.
      #
      # * commit - Instance of CodeFumes::Commit to associate the Build with
      # * name   - A name for the build ('ie7', 'specs', etc.)
      # * state  - Current state of the build (defaults: 'running')
      #   * valid values: 'running', 'failed', 'successful'
      # * options - Hash of additional options. Accepts the following:
      #   * :started_at - Time the build started
      #   * :ended_at   - Time the build completed (defaults to nil)
      def initialize(commit, name, state = 'running', options = {})
        @commit     = commit
        @project    = commit.project
        @name       = name
        @state      = state.to_s
        @started_at = options[:started_at] || options['started_at'] || Time.now
        @ended_at   = options[:ended_at]   || options['ended_at']
      end

      # Overrides existing attributes with those supplied in +options+. This
      # simplifies the process of updating an object's state when given a response
      # from the CodeFumes API.
      #
      # Valid options are:
      # * identifier
      # * name
      # * state
      # * started_at
      # * ended_at
      # * api_uri
      #
      # Returns +self+
      def reinitialize_from_hash!(options = {})
        @identifier          = options[:identifier]        || options['identifier']
        @name                = options[:name]              || options['name']
        @state               = options[:state]             || options['state']
        @api_uri             = options[:api_uri]           || options['api_uri']
        @started_at          = options[:started_at]        || options['started_at']
        @ended_at            = options[:ended_at]          || options['ended_at']
        @created_at          = options[:created_at]        || options['created_at']
        self
      end

      # Saves the Build instance to CodeFumes.com
      #
      # Returns +true+ if successful
      #
      # Returns +false+ if request fails
      # ---
      # TODO: Make this consistent w/ other class' create/update handling
      def save
        response = exists? ? update : create

        case response.code
          when 201,200
            reinitialize_from_hash!(response['build'])
            true
          else
            false
        end
      end

      # Searches website for Build with the supplied identifier.
      #
      # Returns a Build instance if the Build exists and is available,
      # to the user making the request.
      #
      # Returns +nil+ in all other cases.
      def self.find(commit, build_name)
        project = commit.project
        uri = "/projects/#{project.public_key}/commits/#{commit.identifier}/builds/#{build_name}"

        response = API.get(uri)

        case response.code
          when 200
            build_params = response["build"] || {}
            name = build_params["name"]
            state = build_params["state"]
            build = Build.new(commit, name, state)
            build.reinitialize_from_hash!(build_params)
          else
            nil
        end
      end


      # Returns true if the request was successful
      #
      # Returns +false+ in all other cases.
      def destroy
        uri = "/projects/#{@project.public_key}/commits/#{@commit.identifier}/builds/#{@name}"
        auth_args = {:username => @project.public_key, :password => @project.private_key}

        response = API.delete(uri, :basic_auth => auth_args)

        case response.code
          when 200 : true
          else false
        end
      end

      private
        # Verifies existence of Build on website.
        #
        # Returns +true+ if a build with the specified identifier or name is associated with
        # the specified project/commit
        #
        # Returns +false+ if the public key of the Project is not available.
        def exists?
          !self.class.find(commit, name).nil?
        end

        # Saves a new build (makes POST request)
        def create
          API.post("/projects/#{project.public_key}/commits/#{commit.identifier}/builds", :query => {:build => standard_content_hash}, :basic_auth => {:username => project.public_key, :password => project.private_key})
        end

        # Updates an existing build (makes PUT request)
        def update
          API.put("/projects/#{project.public_key}/commits/#{commit.identifier}/builds/#{name}", :query => {:build => standard_content_hash}, :basic_auth => {:username => project.public_key, :password => project.private_key})
        end

        def standard_content_hash
          {:name => name,:started_at => started_at, :ended_at => ended_at, :state => state}
        end
    end
  end
end
