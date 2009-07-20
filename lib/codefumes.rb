def add_dir_to_load_path(dir_path)
  $:.unshift(dir_path) unless
    $:.include?(dir_path) || $:.include?(File.expand_path(dir_path))
end

add_dir_to_load_path(File.dirname(__FILE__))
add_dir_to_load_path(File.dirname(__FILE__) + '/codefumes')

require 'rubygems'
gem 'httparty', '>= 0.4.3'
require 'httparty'

require 'project'
require 'config_file'
require 'payload'
require 'commit'

module CodeFumes
  VERSION = '0.0.1'
end
