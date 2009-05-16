module Codometer
  class Project
    include HTTParty
    base_uri 'http://www.codometer.net/api/v1/xml'
    format :xml
    attr_reader :id, :private_key, :short_uri, :community_uri, :api_uri
    attr_accessor :name, :public_key

    def initialize(options = {})
      @public_key = options[:public_key]
      @name = options[:name]
    end

    def current_version
    end

    def add_version(version)
    end

    def delete
      response = self.class.delete("/projects/#{id}")
      case response.code
      when 200
        return true
      else
        return false
      end
    end

    def save
      response = self.class.post('/projects')

      case response.code
      when 201
        @public_key    = response['project']['public_key']
        @private_key   = response['project']['private_key']
        @short_uri     = response['project']['short_uri']
        @community_uri = response['project']['community_uri']
        @api_uri       = response['project']['api_uri']
        @id            = response['project']['id']
        true
      else
        false
      end
    end

    def to_config
      {public_key.to_sym => [{:private_key => @private_key}, {:api_uri => @api_uri}, {:short_uri => @short_uri}]}
    end
  end
end
