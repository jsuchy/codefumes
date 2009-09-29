module CodeFumes
  class Claim < CodeFumes::API
    attr_accessor :created_at
    SUPPORTED_VISIBILITIES = [:public, :private]

    # Attempts to claim the specified Project instance using the
    # supplied API key.
    #
    # Similar to Project#claim, but more explicit.
    #
    # Returns true if the request is successful.
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
  end
end
