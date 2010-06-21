module CodeFumes
  # A Build represents a specific instance of tests running on
  # a continuous integration server.  Builds have a name and are
  # associated with # a specific Commit of a Project and can track
  # the current status (running, failed, success) and the
  # start & end times of the Build process.
  class Build < CodeFumes::API
    attr_reader   :created_at, :api_uri, :identifier, :commit, :project
    attr_accessor :started_at, :ended_at, :state, :name

    # Initializes new instance of a Build.
    #
    # * commit - Instance of CodeFumes::Commit to associate the Build with
    # * name   - A name for the build ('ie7', 'specs', etc.)
    # * state  - Current state of the build (valid values: 'running', 'failed', 'successful', defaults to 'running')
    # * options - Hash of additional options. Accepts the following:
    #   * :started_at - Time the build started (defaults to Time.now)
    #   * :ended_at   - Time the build completed (defaults to nil)
    #
    # Accepts an +options+ Hash with support for the following keys:
    #   :public_key (*)
    #   :private_key (*)
    #   :commit_identifier (*)
    #   :identifier
    #   :name (*)
    #   :state (*)
    #   :api_uri
    #   :started_at (*)
    #   :ended_at
    #
    #   NOTE:  (*) denotes a required key/value pair
    def initialize(commit, name, state = 'running', options = {})
      @commit     = commit
      @project    = commit.project
      @name       = name
      @state      = state
      @started_at = options[:started_at] || options['started_at'] || Time.now
      @ended_at   = options[:ended_at]   || options['ended_at']
    end

    def xml_init(options = {})
      @project_public_key  = options[:public_key]        || options['public_key']
      @project_private_key = options[:private_key]       || options['private_key']
      @commit_identifier   = options[:commit_identifier] || options['commit_identifier']
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
    def save
      response = exists? ? update : create

      case response.code
        when 201,200
          xml_init(response['build'])
          #@identifier = response['build']['identifier']
          #@name       = response['build']['name']
          #@created_at = response['build']['created_at']
          #@started_at = response['build']['started_at']
          #@ended_at   = response['build']['ended_at']
          #@state     = response['build']['state']
          #@api_uri    = response['build']['build_api_uri']
          #@commit_identifier  = response['build']['commit_identifier']
          #@project_public_key  = response['build']['public_key']
          #@project_private_key = response['build']['private_key']
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

      response = get(uri)

      case response.code
        when 200
          build_params = response["build"] || {}
          name = build_params.delete("name")
          state = build_params.delete("state")
          build = Build.new(commit, name, state)
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

      response = self.class.delete(uri, :basic_auth => auth_args)

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
        content = standard_content_hash
        self.class.post("/projects/#{project.public_key}/commits/#{commit.identifier}/builds", :query => {:build => content}, :basic_auth => {:username => project.public_key, :password => project.private_key})
      end

      # Updates an existing build (makes PUT request)
      def update
        content = standard_content_hash
        self.class.put("/projects/#{project.public_key}/commits/#{commit.identifier}/builds/#{name}", :query => {:build => content}, :basic_auth => {:username => project.public_key, :password => project.private_key})
      end

      def standard_content_hash
        {:name => name,:started_at => started_at, :ended_at => ended_at, :state => state}
      end
  end
end
