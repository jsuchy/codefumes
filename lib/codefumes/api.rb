require 'httparty'
require 'chronic'

require 'codefumes/api/build'
require 'codefumes/api/claim'
require 'codefumes/api/commit'
require 'codefumes/api/payload'
require 'codefumes/api/project'

module CodeFumes
  module API
    include HTTParty
    base_uri 'http://codefumes.com/api/v1/xml'
    format :xml

    BASE_URIS = {
      :production => 'http://codefumes.com/api/v1/xml',
      :test       => 'http://test.codefumes.com/api/v1/xml',
      :local      => 'http://codefumes.com.local/api/v1/xml'
    } #:nodoc:

    def self.mode(mode)
      base_uri(BASE_URIS[mode]) if BASE_URIS[mode]
    end

  end
end
