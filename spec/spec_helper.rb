require 'ruby-debug'
require 'fakeweb'

begin
  require 'spec/autorun'
rescue LoadError
  require 'spec'
end

# For autospec...there has to be a better solution
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'codefumes'

require 'spec/codefumes_service_helpers'
include CodeFumesServiceHelpers::Shared

include CodeFumes

ENV['CODEFUMES_CONFIG_FILE'] = File.expand_path(File.dirname(__FILE__) + '/sample_codefumes_config.tmp')
GIT_FIXTURE_REPO_PATH = File.expand_path(File.dirname(__FILE__) + "/fixtures/sample_project_dirs/git_repository")

class ResponseFixtureSet
  def [](response_fixture)
    "spec/fixtures/#{response_fixture.to_s}.xml"
  end
end
