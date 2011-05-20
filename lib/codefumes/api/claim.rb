module CodeFumes
  module API
    class Claim
      attr_accessor :created_at
      SUPPORTED_VISIBILITIES = [:public, :private]

      # Attempts to claim the specified Project instance using the
      # supplied API key.
      #
      # +visibility+ defaults to +:public+. Valid options are +public+
      # and +private+.
      #
      # Similar to Project#claim, but more explicit.
      #
      # Returns +true+ if the request is successful, or if the project
      # was already owned by the user associated with the privided API
      # key.
      #
      # Returns +false+ in all other cases.
      def self.create(project, api_key, visibility = :public)
        validate_api_key(api_key)
        validate_visibility(visibility)

        auth_args = {:username => project.public_key, :password => project.private_key}

        uri = "/projects/#{project.public_key}/claim"
        response = API.put(uri, :query => {:api_key => api_key, :visibility => visibility}, :basic_auth => auth_args)

        response.code == 200
      end

      # Removes a claim on the specified Project instance using the
      # supplied API key, releasing ownership.  If the project was a
      # "private" project, this method will convert it to "public".
      #
      # Returns true if the request was successful or there was not
      # an existing owner (the action is idempotent).
      #
      # Returns +false+ in all other cases.
      def self.destroy(project, api_key)
        validate_api_key(api_key)

        auth_args = {:username => project.public_key, :password => project.private_key}

        uri = "/projects/#{project.public_key}/claim"
        response = API.delete(uri, :query => {:api_key => api_key}, :basic_auth => auth_args)

        response.code == 200
      end

      private
        def self.validate_api_key(api_key)
          if api_key.nil? || api_key.empty?
            msg = "Invalid user api key provided. (provided: '#{api_key}')"
            raise(Errors::NoUserApiKeyError, msg)
          end
        end

        def self.validate_visibility(visibility)
          unless SUPPORTED_VISIBILITIES.include?(visibility.to_sym)
            msg = "Unsupported visibility supplied (#{visibility.to_s}). "
            msg << "Valid options are: #{SUPPORTED_VISIBILITIES.join(', ')}"
            raise ArgumentError, msg
          end
        end
    end
  end
end
