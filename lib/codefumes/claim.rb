module CodeFumes
  class Claim < CodeFumes::API
    attr_accessor :created_at

    def initialize(options = {})
      options ||= {} # handle nil as argument
      @created_at = options['created_at']
    end

    def self.create(project, api_key)
      auth_args = {:username => project.public_key, :password => project.private_key}

      uri = "/projects/#{project.public_key}/claim"
      response = post(uri, :query => {:api_key => api_key}, :basic_auth => auth_args)
      case response.code
        when 201
          new(response['claim'])
        else nil
      end
    end
  end
end
