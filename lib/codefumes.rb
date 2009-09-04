$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'httparty'

require 'codefumes/api'
require 'codefumes/project'
require 'codefumes/config_file'
require 'codefumes/payload'
require 'codefumes/commit'

module CodeFumes
  VERSION = '0.1.0'
end
