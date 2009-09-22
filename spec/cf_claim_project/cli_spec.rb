require 'spec/spec_helper'
require 'lib/cf_claim_project/cli'

describe CfClaimProject::CLI, "execute" do
  before(:each) do
    ConfigFile.save_credentials("sample_credentials")
    Project.stub!(:find).and_return(mock(Project))
    @stdout_io = StringIO.new
  end

  it "calls Claim#create" do
    Claim.should_receive(:create)
    CfClaimProject::CLI.execute(@stdout_io, [])
  end
end
