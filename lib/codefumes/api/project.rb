module CodeFumes
  module API
    # A Project encapsulates the concept of a project on the CodeFumes.com
    # website.  Each project has a public key, private key, and can have a
    # name defined.  Projects are also associated with a collection of
    # commits from a repository.
    class Project < CodeFumes::API::Foundation
      attr_reader :private_key, :short_uri, :community_uri, :api_uri, :build_status
      attr_accessor :name, :public_key

      def initialize(public_key=nil, private_key = nil, options = {})
        @public_key    = public_key
        @private_key   = private_key
        @name          = options['name']          || options[:name]
        @short_uri     = options['short_uri']     || options[:short_uri]
        @community_uri = options['community_uri'] || options[:community_uri]
        @api_uri       = options['api_uri']       || options[:api_uri]
        @build_status  = options['build_status']  || options[:build_status]
      end

      # Creates new project
      # --
      # TODO: Merge this in with #save
      def self.create
        response = post('/projects')

        case response.code
          when 201
            Project.new.reinitialize_from_hash!(response['project'])
          else
            false
        end
      end

      # Deletes project from the website. You must have both the +public_key+
      # and +private_key+ of a project in order to delete it.
      #
      # Returns +true+ if the request succeeded.
      #
      # Returns +false+ if the request failed.
      def delete
        if public_key.nil? || private_key.nil?
          msg = "You must have both the private key & public key of a project in order to delete it. (currently: {:private_key => '#{private_key.to_s}', :public_key => '#{public_key.to_s}'}"
          raise Errors::InsufficientCredentials, msg
        end

        response = destroy!
        case response.code
          when 200
            return true
          else
            return false
        end
      end

      # Attempts to save current state of project to CodeFumes.
      #
      # Returns +true+ if the request succeeded.
      #
      # Returns +false+ if the request failed.
      def save
        response = self.class.put("/projects/#{public_key}", :query => {:project => {:name => name}},
                                  :basic_auth => {:username => public_key, :password => private_key})

        case response.code
          when 200
            reinitialize_from_hash!(response['project'])
            true
          else
            false
        end
      end

      # Serializes a Project instance to a format compatible with the
      # CodeFumes config file.
      def to_config
        project_attributes = {:api_uri => api_uri, :short_uri => short_uri}
        project_attributes[:private_key] = private_key unless private_key.nil?
        {public_key.to_sym => project_attributes}
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
            project.reinitialize_from_hash!(response['project'])
          else
            nil
        end
      end

      # Overrides existing attributes with those supplied in +options+. This
      # simplifies the process of updating an object's state when given a response
      # from the CodeFumes API.
      #
      # Valid options are:
      # * public_key
      # * private_key
      # * short_uri
      # * community_uri
      # * api_uri
      # * build_status
      #
      # Returns +self+
      def reinitialize_from_hash!(options = {}) #:nodoc:
        @name          = options['name']          || options[:name]
        @public_key    = options['public_key']    || options[:public_key]
        @private_key   = options['private_key']   || options[:private_key]
        @short_uri     = options['short_uri']     || options[:short_uri]
        @community_uri = options['community_uri'] || options[:community_uri]
        @api_uri       = options['api_uri']       || options[:api_uri]
        @build_status  = options['build_status']  || options[:build_status]
        self
      end

      # Attempts to claim "ownership" of the project using the API key
      # defined in the "credentials" section of your CodeFumes config
      # file.
      #
      # If you need to claim a project for a key that is not defined in
      # your config file, refer to Claim#create.
      #
      # Returns true if the request is successful.
      #
      # Returns +false+ in all other cases.
      def claim
        Claim.create(self, ConfigFile.api_key)
      end

      private
        def destroy!
          self.class.delete("/projects/#{@public_key}", :basic_auth => {:username => @public_key, :password => @private_key})
        end
    end
  end
end
