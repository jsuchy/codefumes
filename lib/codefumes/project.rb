module CodeFumes
  # A Project encapsulates the concept of a project on the CodeFumes.com
  # website.  Each project has a public key, private key, and can have a
  # name defined.  Projects are also associated with a collection of
  # commits from a repository.
  class Project < CodeFumes::API
    attr_reader :private_key, :short_uri, :community_uri, :api_uri
    attr_accessor :name,:public_key

    # Accepts Hash containing the following keys:
    # * :public_key
    # * :private_key
    # * :name
    def initialize(options = {})
      @public_key = options[:public_key]
      @private_key = options[:private_key]
      @name = options[:name]
    end

    # Deletes project from the website.
    #
    # Returns +true+ if the request succeeded.
    #
    # Returns +false+ if the request failed.
    def delete
      response = destroy!
      case response.code
        when 200
          return true
        else
          return false
      end
    end

    # Saves project +:public_key+ to the website. If the public key
    # of the project has not been reserved yet, it will attempt to do
    # so. If the public key of the project is already in use, it will
    # attempt to update it with the current values.
    #
    # Returns +true+ if the request succeeded.
    #
    # Returns +false+ if the request failed.
    def save
      response = exists? ? update : create
      case response.code
        when 201, 200
          reinitialize!(response)
          true
        else
          false
      end
    end

    # Serializes a Project instance to a format compatible with the
    # CodeFumes config file.
    def to_config
      project_attributes = {:api_uri => @api_uri, :short_uri => @short_uri}
      project_attributes[:private_key] = @private_key if @private_key
      {@public_key.to_sym => project_attributes}
    end

    # Verifies existence of Project on website.
    #
    # Returns +true+ if the public key of Project is available.
    #
    # Returns +false+ if the public key of the Project is not available.
    def exists?
      return false if @public_key.nil? || @public_key.empty?
      !self.class.find(@public_key).nil?
    end


    # Searches website for project with the supplied public key.
    #
    # Returns a Project instance if the project exists and is available,
    # to the user making the request.
    #
    # Returns +nil+ in all other cases.
    def self.find(public_key)
      response = get("/projects/#{public_key}")
      case response.code
        when 200
          project = Project.new
          project.reinitialize!(response)
        else
          nil
      end
    end

    # TODO: Make this a private method
    def reinitialize!(options = {}) #:nodoc:
      @public_key    = options['project']['public_key']
      @private_key   = options['project']['private_key']
      @short_uri     = options['project']['short_uri']
      @community_uri = options['project']['community_uri']
      @api_uri       = options['project']['api_uri']
      self
    end

    def claim
      Claim.create(self, ConfigFile.credentials[:api_key])
    end

    private
      def update
        self.class.put("/projects/#{@public_key}", :query => {:project => {:name => @name}}, :basic_auth => {:username => @public_key, :password => @private_key})
      end

      def create
        self.class.post('/projects', :query => {:project => {:name => @name, :public_key => @public_key}})
      end

      def destroy!
        self.class.delete("/projects/#{@public_key}", :basic_auth => {:username => @public_key, :password => @private_key})
      end
  end
end
