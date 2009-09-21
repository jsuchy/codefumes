require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Claim do
  after(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  before(:each) do
    @api_key = "USERS_API_KEY"
    @project = Project.new(:public_key => 'public_key_value', :private_key => 'private_key_value')
    @claim_uri = "http://www.codefumes.com/api/v1/xml/projects/#{@project.public_key}/claim?api_key=#{@api_key}"
  end

  context "with 201 Created response" do
    it "returns an instance of Claim with the created_at attribute set" do
      @timestamp = "TIMESTAMP"
      FakeWeb.register_uri( :post, @claim_uri,
                            :status => ["201", "Created"],
                            :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<claim>\n<created_at>#{@timestamp}</created_at></claim>\n")
      claim = Claim.create(@project, @api_key)
      claim.should be_instance_of(Claim)
      claim.created_at.should == @timestamp
    end
  end

  context "with Unauthorized response" do
    it "returns nil" do
      FakeWeb.register_uri( :post, @claim_uri,
                            :status => ["401", "Unauthorized"],
                            :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<claim>\n</claim>\n")
      Claim.create(@project, @api_key).should == nil
    end
  end
end
