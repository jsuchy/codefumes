require File.dirname(__FILE__) + '/../spec_helper.rb'

def register_create_uri
  FakeWeb.register_uri( :post, "http://www.codometer.net/api/v1/xml/projects",
                        :status => ["201", "Created"],
                        :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<project>\n  <access-secret nil=\"true\"></access-secret>\n  <created-at type=\"datetime\">2009-04-29T23:18:03Z</created-at>\n  <id type=\"integer\">1</id>\n  <public-key>foofoolerue</public-key>\n <private-key>foobarbaz</private-key>\n  <updated-at type=\"datetime\">2009-04-29T23:18:03Z</updated-at>\n</project>\n <short_uri>http://www.codometer.net/p/foofoolerue</short_uri>\n <community_uri>http://www.codometer.net/community/projects/1</community_uri>\n <api-uri>http://www.codometer.net/api/v1/xml/projects/1.xml</api-uri>\n")
end

describe "Project" do
  after(:all) do
    FakeWeb.clean_registry
  end

  context "creating a new project" do 
    context "successfully" do
      before(:each) do
        register_create_uri
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

      [:private_key, :id].each do |method_name|
        it "does not set the '#{method_name.to_s}'" do
          project = Codometer::Project.new
          project.save.should be_false
          project.send(method_name).should be_nil
        end
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
      register_create_uri
      @project = Project.new
      @project.save
    end

    it "returns an object keyed by the project's public_key as a symbol" do
      @project.to_config.should include(@project.public_key.to_sym)
    end

    context "the content under the project's public_key element" do
      [:private_key, :api_uri, :short_uri].each do |project_attribute|
        it "includes a key-value pair of ':#{project_attribute.to_s} => [project's #{project_attribute.to_s}]'" do
          value = @project.send(project_attribute)
          @project.to_config[@project.public_key.to_sym].should include(project_attribute => value)
        end
      end
    end
  end

  describe "protected attributes" do
    [:id, :private_key, :api_uri, :community_uri, :short_uri].each do |attribute_name|
      it "values passed in during initiazation for '#{attribute_name.to_s}' are silently ignored" do
        p = Project.new(attribute_name => Time.now.to_s)
        p.send(attribute_name).should be_nil
      end

      it "calling '#{attribute_name.to_s}= [value]' is not supported" do
        p = Project.new
        lambda {p.send("#{attribute_name}=", "my_value")}.should raise_error
      end
    end
  end

  describe "accessible attributes" do
    before(:each) do
      @value = 'my_value'
    end

    [:public_key, :name].each do |attribute_name|
      it "values for '#{attribute_name.to_s}' are allowed to be modified by the client" do
        p = Project.new(attribute_name => @value )
        p.send(attribute_name).should ==  @value
      end
    end
  end
end
