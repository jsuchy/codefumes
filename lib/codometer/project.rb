module Codometer
  class Project
    include HTTParty
    base_uri 'http://www.codometer.net/api/v1/xml'
    format :xml
    attr_accessor :public_key, :private_key, :short_uri, :community_uri, :api_uri

    def initialize(options = {})
      self.public_key = options[:public_key]
      self.private_key = options[:private_key]
    end

    def current_version
    end

    def add_version version
    end

    def save
      response = self.class.post('/projects')

      case response.code
        when 201
          self.public_key    = response['project']['public_key']
          self.private_key   = response['project']['private_key']
          self.short_uri     = response['project']['short_uri']
          self.community_uri = response['project']['community_uri']
          self.api_uri       = response['project']['api_uri']
          true
        else
          false
        end
    end

    def to_config
      {public_key.to_sym => [{:private_key => private_key}]}
    end
  end
end
