require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Project" do
  after(:all) do
    FakeWeb.clean_registry
  end

  context "creating a new project" do 
    context "successfully" do
      before(:each) do
        FakeWeb.register_uri( :post, "http://www.codometer.net/api/v1/xml/projects",
                              :status => ["201", "Created"],
                              :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<project>\n  <access-secret nil=\"true\"></access-secret>\n  <created-at type=\"datetime\">2009-04-29T23:18:03Z</created-at>\n  <id type=\"integer\">1</id>\n  <public-key>foofoolerue</public-key>\n <private-key>foobarbaz</private-key>\n  <updated-at type=\"datetime\">2009-04-29T23:18:03Z</updated-at>\n</project>\n")
      end
      it "sets the public key" do
        project = Codometer::Project.new
        project.public_key.should be_nil
        project.save
        project.public_key.should_not be_nil
      end

      it "sets the private key" do
        project = Codometer::Project.new
        project.private_key.should be_nil
        project.save
        project.private_key.should_not be_nil
      end
    end

    context "unsuccessfully" do
      before(:each) do
          FakeWeb.register_uri( :post, "http://www.codometer.net/api/v1/xml/projects",
                                :status => ["422", "Unprocessable Entity"])
      end

      it "doesn't set the public key" do
        project = Codometer::Project.new
        project.save.should be_false
        project.public_key.should be_nil
        project.private_key.should be_nil
      end
    end
  end

  describe "to_config" do
    before(:each) do
      @project = Project.new(:public_key => 'jKly', :private_key => '1234567890')
    end

    it "returns an object keyed by the project's public_key as a symbol" do
      @project.to_config.should include(:jKly)
    end

    context "the content under the project's public_key element" do
      it "includes a key-value pair of ':private_key => [project's private key]'" do
        @project.to_config[@project.public_key.to_sym].should include(:private_key => @project.private_key)
      end
    end
  end
end
