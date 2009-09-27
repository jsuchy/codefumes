require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Claim do
  include CodeFumesServiceHelpers::Claim

  after(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  before(:all) do
    setup_fixture_base
  end

  describe "create" do
    context "with '201 Created' response" do
      it "returns true" do
        register_create_uri
        Claim.create(@project, @api_key).should be_true
      end
    end

    context "with '401 Unauthorized' response" do
      it "returns false" do
        register_create_uri(["401", "Unauthorized"])
        Claim.create(@project, @api_key).should be_false
      end
    end
  end
end
