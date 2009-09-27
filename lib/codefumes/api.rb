module CodeFumes
  class API
    include HTTParty

    format :xml

    BASE_URIS = {
      :production => 'http://codefumes.com/api/v1/xml',
      :test       => 'http://test.codefumes.com/api/v1/xml',
      :local      => 'http://localhost:3000/api/v1/xml'
    }

    def self.mode(mode)
      base_uri(BASE_URIS[mode]) if BASE_URIS[mode]
    end

    mode(:production)

  end
end
