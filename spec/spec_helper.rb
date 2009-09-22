require 'rubygems'
require 'ruby-debug'
require 'fakeweb'

begin
  require 'spec/autorun'
rescue LoadError
  require 'spec'
end

require 'lib/codefumes'

# CodeFumes service 'fixtures'
require 'spec/codefumes_service_stubs'

include CodeFumes

ENV['CODEFUMES_CONFIG_FILE'] = File.expand_path(File.dirname(__FILE__) + '/sample_codefumes_config.tmp')
