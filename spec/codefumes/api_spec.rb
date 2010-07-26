require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "API" do
  after(:all) do
    CodeFumes::API.mode(:production)
  end

  it "defaults the base uri to the production site" do
    API.base_uri.should == 'http://codefumes.com/api/v1/xml'
  end

  context "switching modes" do
    before(:each) do
      API.mode(:test)
    end

    it "changes the base uri to the test site when switched to test mode" do
      API.base_uri.should == 'http://test.codefumes.com/api/v1/xml'
    end

    it "changes the base uri to the production site when switched to production mode" do
      API.mode(:production)
      API.base_uri.should == 'http://codefumes.com/api/v1/xml'
    end

    it "ignores unrecognized modes" do
      API.mode(:incomprehensible)
      API.base_uri.should == 'http://test.codefumes.com/api/v1/xml'
    end

    it "changes the base uri to 'codefumes.com.local' when switched to local mode (for developer testing)" do
      API.mode(:local)
      API.base_uri.should == 'http://codefumes.com.local/api/v1/xml'
    end
  end
end
