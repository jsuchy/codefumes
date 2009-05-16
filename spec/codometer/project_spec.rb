require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Project" do
  after(:all) do
    FakeWeb.clean_registry
  end

  after(:each) do
    FakeWeb.clean_registry
  end

  context "creating a new project" do 
    context "successfully" do
      before(:each) do
        FakeWeb.register_uri( :post, "http://www.codometer.net/api/v1/xml/projects",
                              :status => ["201", "Created"],
                              :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<project>\n  <access-secret nil=\"true\"></access-secret>\n  <created-at type=\"datetime\">2009-04-29T23:18:03Z</created-at>\n  <id type=\"integer\">1</id>\n  <public-key>foofoolerue</public-key>\n <private-key>foobarbaz</private-key>\n  <updated-at type=\"datetime\">2009-04-29T23:18:03Z</updated-at>\n</project>\n <short_uri>http://www.codometer.net/p/foofoolerue</short_uri>\n <community_uri>http://www.codometer.net/community/projects/1</community_uri>\n <api-uri>http://www.codometer.net/api/v1/xml/projects/1.xml</api-uri>\n")
      end

      [ :public_key,
        :private_key,
        :short_uri,
        :community_uri,
        :api_uri,
        :id].each do |method_name|
          it "sets the '#{method_name.to_s}'" do
            project = Codometer::Project.new
            project.send(method_name).should be_nil
            project.save
            project.send(method_name).should_not be_nil
          end
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

  context "deleting a project" do
    before(:each) do
      @project = Project.new(:public_key => 'jKly', :private_key => '1234567890')
      @project.stub!(:id).and_return(1)
      FakeWeb.register_uri( :delete, "http://www.codometer.net/api/v1/xml/projects/1",
                            :status => ["200", "Successful"],
                            :string =>  "")
    end

    it "returns true" do
      @project.delete.should be_true
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
