require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "API" do
  after(:all) do
    CodeFumes::API.mode = :production
  end

  it "defaults the base uri to the production site" do
    API.base_uri.should == 'http://codefumes.com/api/v1/xml'
  end

  context "switching modes" do
    before(:each) do
      API.mode = :test
    end

    it "changes the base uri to the test site when switched to test mode" do
      API.base_uri.should == API::BASE_URIS[:test]
    end

    it "changes the base uri to the production site when switched to production mode" do
      API.mode = :production
      API.base_uri.should == API::BASE_URIS[:production]
    end

    it "ignores unrecognized modes" do
      API.mode = :incomprehensible
      API.base_uri.should == API::BASE_URIS[:test]
    end

    it "treats empty Strings as an unrecognized mode" do
      API.mode = ''
      API.base_uri.should == API::BASE_URIS[:test]
    end

    it "treats nil as an unrecognized mode" do
      API.mode = nil
      API.base_uri.should == API::BASE_URIS[:test]
    end

    it "supports String versions of the supported modes" do
      API.base_uri.should == API::BASE_URIS[:test]
      API.mode = 'production'
      API.base_uri.should == API::BASE_URIS[:production]
    end

    it "changes the base uri to 'codefumes.com.local' when switched to local mode (for developer testing)" do
      API.mode = :local
      API.base_uri.should == API::BASE_URIS[:local]
    end
  end
  context "#mode?" do
    specify {API.mode?(:production).should == true}
    specify {API.mode?('production').should == true}
    specify {API.mode?(:test).should == false}
    specify {API.mode?(:anything).should == false}
    specify {API.mode?(nil).should == false}

    it "does not modify the existing mode" do
      lambda {API.mode?(:test)}.should_not change(API, :base_uri)
    end
  end
end
