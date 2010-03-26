module CodeFumes
  class Build < CodeFumes::API
    attr_reader   :project_public_key, :project_private_key, :created_at, :api_uri, :identifier, :commit_identifier
    attr_accessor :started_at, :ended_at, :state, :name

    def initialize(options = {})
      @project_public_key  = options[:public_key]        || options['public_key']
      @project_private_key = options[:private_key]       || options['private_key']
      @commit_identifier   = options[:commit_identifier] || options['commit_identifier']
      @identifier          = options[:identifier]        || options['identifier']
      @name                = options[:name]              || options['name']
      @state               = options[:state]             || options['state']
      @api_uri             = options[:api_uri]           || options['api_uri']
      @started_at          = options[:started_at]        || options['started_at']
      @ended_at            = options[:ended_at]          || options['ended_at']
    end

    def save
      response = exists? ? update : create

      case response.code
        when 201,200
          @identifier = response['build']['identifier']
          @name       = response['build']['name']
          @created_at = response['build']['created_at']
          @started_at = response['build']['started_at']
          @ended_at   = response['build']['ended_at']
          @state     = response['build']['state']
          @api_uri    = response['build']['build_api_uri']
          @commit_identifier  = response['build']['commit_identifier']
          @project_public_key  = response['build']['public_key']
          @project_private_key = response['build']['private_key']
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
    def self.find(options)
      uri = "/projects/#{options[:public_key]}/commits/#{options[:commit_identifier]}/builds/#{options[:identifier]}"

      response = get(uri)

      case response.code
        when 200
          build_params = response["build"] || {}
          Build.new(build_params.merge(:private_key => options[:private_key]))
        else
          nil
      end
    end


    # Returns true if the request was successful
    #
    # Returns +false+ in all other cases.
    def destroy
      uri = "/projects/#{@project_public_key}/commits/#{@commit_identifier}/builds/#{@identifier}"
      auth_args = {:username => @project_public_key, :password => @project_private_key}

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
        !self.class.find(:public_key         => @project_public_key,
                         :commit_identifier  => @commit_identifier,
                         :identifier         => @identifier || @name,
                         :private_key        => @project_private_key).nil?
      end

      def create
        content = standard_content_hash
        self.class.post("/projects/#{@project_public_key}/commits/#{@commit_identifier}/builds", :query => {:build => content}, :basic_auth => {:username => @project_public_key, :password => @project_private_key})
      end

      def update
        content = standard_content_hash
        self.class.put("/projects/#{@project_public_key}/commits/#{@commit_identifier}/builds/#{@identifier}", :query => {:build => content}, :basic_auth => {:username => @project_public_key, :password => @project_private_key})
      end

      def standard_content_hash
        {:name => @name,:started_at => @started_at, :ended_at => @ended_at, :state => @state}
      end
  end
end
