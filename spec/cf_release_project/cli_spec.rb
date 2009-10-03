require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'cf_release_project/cli'

def delete_config_file
  unless ConfigFile.path == File.expand_path('~/.codefumes_config')
    File.delete(ConfigFile.path) if File.exist?(ConfigFile.path)
  end
end

def execute_command(args)
  @stdout_io = StringIO.new
  CfReleaseProject::CLI.execute(@stdout_io, [args])
  @stdout_io.rewind
  @stdout = @stdout_io.read
end


describe CfReleaseProject::CLI, "execute" do
  before(:each) do
    @api_key = "my_credentials"
    @project = Project.new(:public_key => "abc", :private_key => "382")
    ConfigFile.save_project(@project)
    ConfigFile.save_credentials(@api_key)
    Project.stub!(:find).and_return(@project)
    Claim.stub!(:destroy).with(@project, @api_key)
  end

  after(:all) do
    delete_config_file
  end

  it "deletes the claim on the project" do
    Claim.should_receive(:destroy).with(@project, @api_key)
    execute_command(@project.public_key)
  end

  it "should print default output" do
    execute_command(@project.public_key)
    @stdout.should =~ /Done/
  end
end
