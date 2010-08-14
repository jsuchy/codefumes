require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "API::Claim" do
  include CodeFumesServiceHelpers::ClaimHelpers

  after(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  before(:all) do
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    setup_fixture_base
  end

  describe "create" do
    context "with '200 Ok' response" do
      it "returns true" do
        register_public_create_uri
        Claim.create(@project, @api_key).should be_true
      end
    end

    context "with '401 Unauthorized' response" do
      it "returns false" do
        register_public_create_uri(["401", "Unauthorized"])
        Claim.create(@project, @api_key).should be_false
      end
    end

    context "setting visibility" do
      it "supports 'public'" do
        register_public_create_uri
        Claim.create(@project, @api_key, :public).should be_true
        Claim.create(@project, @api_key).should be_true
      end

      it "supports 'private'" do
        register_private_create_uri
        Claim.create(@project, @api_key, :private).should be_true
      end

      it "raises an ArgumentError if an unsupported visibility type is provided" do
        lambda {
          Claim.create(@project, @api_key, :unsupported_visibility)
        }.should raise_error(ArgumentError)
      end
    end

    context "a nil value is passed in for the api_key" do
      it "should not hit the CodeFumes API" do
        API.should_not_receive(:put)
        lambda {Claim.create(@project, nil)}
      end

      it "raises a NoUserApiKeyError" do
        lambda {
          Claim.create(@project, nil)
        }.should raise_error(Errors::NoUserApiKeyError)
      end
    end

    context "an empty string is passed in for the api_key" do
      it "should not hit the CodeFumes API" do
        API.should_not_receive(:put)
        lambda {Claim.create(@project, '')}
      end

      it "raises a NoUserApiKeyError" do
        lambda {
          Claim.create(@project, '')
        }.should raise_error(Errors::NoUserApiKeyError)
      end
    end
  end

  describe "destroy" do
    context "with '200 Ok' response" do
      it "returns true" do
        register_destroy_uri
        Claim.destroy(@project, @api_key).should be_true
      end
    end

    context "with '401 Unauthorized' response" do
      it "returns false" do
        register_destroy_uri(["401", "Unauthorized"])
        Claim.destroy(@project, @api_key).should be_false
      end
    end

    context "a nil value is passed in for the api_key" do
      it "should not hit the CodeFumes API" do
        API.should_not_receive(:delete)
        lambda {Claim.destroy(@project, nil)}
      end

      it "raises a NoUserApiKeyError" do
        lambda {
          Claim.destroy(@project, nil)
        }.should raise_error(Errors::NoUserApiKeyError)
      end
    end
  end
end
