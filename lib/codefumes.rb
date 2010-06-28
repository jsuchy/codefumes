require 'codefumes/api'
require 'codefumes/config_file'
require 'codefumes/errors'

include CodeFumes::API

module CodeFumes
  VERSION = '0.1.10' unless defined?(CodeFumes::VERSION)
end
