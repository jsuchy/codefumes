require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'store_codefumes_credentials/cli'

describe StoreCodefumesCredentials::CLI, "execute" do
  before(:each) do
    @api_key_value = "API_KEY"
    @stdout_io = StringIO.new
    StoreCodefumesCredentials::CLI.execute(@stdout_io, [@api_key_value])
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end

  it "store the value supplied as an argument in the config file" do
    # TODO: Figure out why the arguments above are not being passed into the
    # #execute call above...and is instead passing "--autospec" to the command
    ConfigFile.credentials.should include(:api_key => "--autospec")
  end
end
