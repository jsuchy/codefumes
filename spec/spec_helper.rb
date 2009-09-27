require 'ruby-debug'
require 'fakeweb'

begin
  require 'spec/autorun'
rescue LoadError
  require 'spec'
end

require 'codefumes'

require 'spec/codefumes_service_helpers'
include CodeFumesServiceHelpers::Shared

include CodeFumes

ENV['CODEFUMES_CONFIG_FILE'] = File.expand_path(File.dirname(__FILE__) + '/sample_codefumes_config.tmp')

class ResponseFixtureSet
  def [](response_fixture)
    "spec/fixtures/#{response_fixture.to_s}.xml"
  end
end
