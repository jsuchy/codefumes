require 'rubygems'

begin
  require 'spec/autorun'
rescue LoadError
  gem 'rspec'
  require 'spec'
end

gem 'ruby-debug'
require 'ruby-debug'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'codefumes'
require 'fakeweb'

include CodeFumes

ENV['CODEFUMES_CONFIG_FILE'] = File.expand_path(File.dirname(__FILE__) + '/sample_codefumes_config.tmp')
