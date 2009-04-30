module Codometer
  class Project
    include HTTParty
    base_uri 'http://www.codometer.com'
    format :xml
    attr_accessor :public_key, :private_key
    
    def initialize     
    end
    
    def current_version
    end
    
    def add_version version
    end
    
    def create
      response = self.class.post('/projects')
      case response.code
        when 201
          self.public_key = response['project']['public_key']
          self.private_key = response['project']['private_key']
          true
        else
          false
        end
    end
    
  end
end