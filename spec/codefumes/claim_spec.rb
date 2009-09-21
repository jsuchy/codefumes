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

  describe "create" do
    context "with 201 Created response" do
      it "returns an instance of Claim with the created_at attribute set" do
        FakeWeb.register_uri( :post, @claim_uri, :status => ["201", "Created"], :string =>  "")
        Claim.create(@project, @api_key).should be_true
      end
    end

    context "with Unauthorized response" do
      it "returns false" do
        FakeWeb.register_uri( :post, @claim_uri, :status => ["401", "Unauthorized"], :string =>  "")
        Claim.create(@project, @api_key).should be_false
      end
    end
  end
end
