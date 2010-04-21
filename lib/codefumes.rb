require 'httparty'
require 'chronic'

require 'codefumes/api'
require 'codefumes/build'
require 'codefumes/claim'
require 'codefumes/commit'
require 'codefumes/config_file'
require 'codefumes/payload'
require 'codefumes/project'

module CodeFumes
  VERSION = '0.1.10' unless defined?(CodeFumes::VERSION)
end
