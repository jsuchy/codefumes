require 'spec/spec_helper'
require 'lib/cf_claim_project/cli'

describe CfClaimProject::CLI, "execute" do
  before(:each) do
    @project = Project.new("pub", :private_key => "prv_key")
    Project.stub!(:find).and_return(@project)
    ConfigFile.save_credentials("sample_credentials")
    ConfigFile.save_project(@project)
    @stdout_io = StringIO.new
  end

  it "calls Claim#create" do
    Claim.should_receive(:create)
    CfClaimProject::CLI.execute(@stdout_io, [@project.public_key])
  end
end
