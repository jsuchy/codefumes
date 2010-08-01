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

    def self.mode=(mode)
      return if mode.to_s.empty?
      base_uri(BASE_URIS[mode.to_sym]) if BASE_URIS[mode.to_sym]
    end

    def self.mode?(mode)
      return false if mode.nil?
      base_uri == BASE_URIS[mode.to_sym]
    end
  end
end

CodeFumes::API.mode= ENV['FUMES_ENV']
