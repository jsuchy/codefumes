require File.dirname(__FILE__) + "/../../lib/codefumes"

gem 'cucumber'
require 'cucumber'
gem 'rspec'
require 'spec'
require 'spec/stubs/cucumber'

include CodeFumes

gem 'aruba'
require 'aruba'

Before do
  @tmp_root = File.dirname(__FILE__) + "/../../tmp"
  @home_path = File.expand_path(File.join(@tmp_root, "home"))
  @lib_path  = File.expand_path(File.dirname(__FILE__) + "/../../lib")
  @bin_path  = File.expand_path(File.dirname(__FILE__) + "/../../bin")
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
  ENV['CODEFUMES_CONFIG_FILE'] = File.expand_path(File.join(@tmp_root, "codefumes_config_file"))
  ENV['FUMES_ENV'] = ENV['FUMES_ENV'] || "test"
end
