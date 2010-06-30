require 'grit'

require 'codefumes/api'
require 'codefumes/config_file'
require 'codefumes/errors'
require 'codefumes/harvester.rb'
require 'codefumes/quick_build.rb'
require 'codefumes/quick_metric.rb'
require 'codefumes/source_control.rb'

include CodeFumes::API

module CodeFumes
  VERSION = '0.1.10' unless defined?(CodeFumes::VERSION)
end
