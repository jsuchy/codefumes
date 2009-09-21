require 'spec/spec_helper'
require 'lib/store_codefumes_credentials/cli'

describe StoreCodefumesCredentials::CLI, "execute" do
  after(:all) do
    unless ConfigFile.path == File.expand_path('~/.codefumes_config')
      File.delete(ConfigFile.path) if File.exist?(ConfigFile.path)
    end
  end

  before(:each) do
    @api_key_value = "API_KEY"
    @stdout_io = StringIO.new
    StoreCodefumesCredentials::CLI.execute(@stdout_io, [@api_key_value])
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end

  it "store the value supplied as an argument in the config file" do
    ConfigFile.credentials.keys.should include(:api_key)
  end
end
