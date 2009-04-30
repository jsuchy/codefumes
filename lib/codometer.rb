$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
gem 'httparty', '>= 0.4.3'
require 'httparty'

require 'codometer/project'

module Codometer
  VERSION = '0.0.1'
end