require 'spec/spec_helper'
require 'lib/store_codefumes_credentials/cli'

def delete_config_file
  unless ConfigFile.path == File.expand_path('~/.codefumes_config')
    File.delete(ConfigFile.path) if File.exist?(ConfigFile.path)
  end
end

describe StoreCodefumesCredentials::CLI, "execute" do
  after(:all) do
    delete_config_file
  end

  before(:each) do
    delete_config_file
    @api_key_value = "API_KEY#{rand(100)}"
    @stdout_io = StringIO.new
    StoreCodefumesCredentials::CLI.execute(@stdout_io, [@api_key_value])
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end

  it "stores the value supplied in the config file under the key ':api_key'" do
    ConfigFile.credentials.keys.should include(:api_key)
    ConfigFile.credentials[:api_key].should == @api_key_value
  end
end
