module Codometer
  class Payload
    include HTTParty
    base_uri 'http://www.codometer.net/api/v1/xml'
    format :xml
    attr_reader :project_public_key, :content, :created_at

    def initialize(options = {:content => nil})
      @project_public_key = options[:public_key]
      @scm_payload = options[:scm_payload]
    end

    def save
      return true if payload.empty?
      response = self.class.post("/projects/#{@project_public_key}/payloads", :query => {:payload => payload})

      case response.code
      when 201
        @created_at = response['payload']['created_at']
        true
      else
        false
      end
    end

    private
      def payload
        @scm_payload
      end
  end
end
