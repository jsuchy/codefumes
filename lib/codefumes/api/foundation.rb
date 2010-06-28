module CodeFumes
  module API
    class Foundation
      include HTTParty

      format :xml

      BASE_URIS = {
        :production => 'http://codefumes.com/api/v1/xml',
        :test       => 'http://test.codefumes.com/api/v1/xml',
        :local      => 'http://codefumes.com.local/api/v1/xml'
      } #:nodoc:

      # Set the connection base for all server requests. Valid options
      # are +:production+ and +:test+, which connect to
      # http://codefumes.com and http://test.codefumes.com (respectively).
      #
      # +:local+ is also technically supported, but provided for local
      # testing and likely only useful for CodeFumes.com developers.
      def self.mode(mode)
        base_uri(BASE_URIS[mode]) if BASE_URIS[mode]
      end

      mode(:production)
    end
  end
end
