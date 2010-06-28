module CodeFumes
  module API
    class Claim < CodeFumes::API::Foundation
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
        unless SUPPORTED_VISIBILITIES.include?(visibility.to_sym)
          msg = "Unsupported visibility supplied (#{visibility.to_s}). "
          msg << "Valid options are: #{SUPPORTED_VISIBILITIES.join(', ')}"
          raise ArgumentError, msg
        end

        auth_args = {:username => project.public_key, :password => project.private_key}

        uri = "/projects/#{project.public_key}/claim"
        response = put(uri, :query => {:api_key => api_key, :visibility => visibility}, :basic_auth => auth_args)

        case response.code
          when 200 : true
          else false
        end
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
        auth_args = {:username => project.public_key, :password => project.private_key}

        uri = "/projects/#{project.public_key}/claim"
        response = delete(uri, :query => {:api_key => api_key}, :basic_auth => auth_args)

        case response.code
          when 200 : true
          else false
        end
      end
    end
  end
end
