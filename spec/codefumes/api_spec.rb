require File.dirname(__FILE__) + '/../spec_helper.rb'

class APIClass < CodeFumes::API
end

describe "API" do
  after(:all) do
    CodeFumes::API.mode(:production)
  end

  it "defaults the base uri to the production site" do
    APIClass.base_uri.should == 'http://codefumes.com/api/v1/xml'
  end

  context "switching modes" do
    before(:each) do
      CodeFumes::API.mode(:test)
    end

    it "changes the base uri to the test site when switched to test mode" do
      APIClass.base_uri.should == 'http://test.codefumes.com/api/v1/xml'
    end

    it "changes the base uri to the production site when switched to production mode" do
      CodeFumes::API.mode(:production)
      APIClass.base_uri.should == 'http://codefumes.com/api/v1/xml'
    end

    it "ignores unrecognized modes" do
      CodeFumes::API.mode(:incomprehensible)
      APIClass.base_uri.should == 'http://test.codefumes.com/api/v1/xml'
    end

    it "changes the base uri to 'localhost:3000' when switched to local mode (for developer testing)" do
      CodeFumes::API.mode(:local)
      APIClass.base_uri.should == 'http://codefumes.com.local/api/v1/xml'
    end
  end
  
end
