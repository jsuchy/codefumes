require 'rubygems'

begin
  require 'spec'
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
