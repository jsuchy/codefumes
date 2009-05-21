require File.dirname(__FILE__) + '/../spec_helper.rb'

def register_create_uri
  FakeWeb.register_uri( :post, "http://www.codometer.net/api/v1/xml/projects?project[public_key]=&project[name]=",
                        :status => ["201", "Created"],
                        :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<project>\n  <access-secret nil=\"true\"></access-secret>\n  <created-at type=\"datetime\">2009-04-29T23:18:03Z</created-at>\n  <public-key>foofoolerue</public-key>\n <private-key>foobarbaz</private-key>\n  <updated-at type=\"datetime\">2009-04-29T23:18:03Z</updated-at>\n</project>\n <short_uri>http://www.codometer.net/p/foofoolerue</short_uri>\n <community_uri>http://www.codometer.net/community/projects/1</community_uri>\n <api-uri>http://www.codometer.net/api/v1/xml/projects/1.xml</api-uri>\n")
end

def register_update_uri(public_key = "public_key_value", project_name = "The Project Name(tm)")
  FakeWeb.register_uri(:put, "http://www.codometer.net/api/v1/xml/projects/existing_public_key?project[name]=#{project_name}",
                       :status => ["200", "Ok"],
                         :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<project>\n  <access-secret nil=\"true\"></access-secret>\n  <created-at type=\"datetime\">2009-04-29T23:18:03Z</created-at>\n  <public-key>existing_public_key</public-key>\n <private-key>private_key_value</private-key>\n  <updated-at type=\"datetime\">2009-04-29T23:18:03Z</updated-at>\n</project>\n <short_uri>http://www.codometer.net/p/#{public_key}</short_uri>\n <community_uri>http://www.codometer.net/community/projects/#{public_key}</community_uri>\n <api-uri>http://www.codometer.net/api/v1/xml/projects/#{public_key}.xml</api-uri>\n <name>#{project_name}</name>\n")
end

def register_show_uri(public_key = "public_key_value", project_name = "The Project Name(tm)", status_code = ["200", "Ok"])
  FakeWeb.register_uri(:get, "http://www.codometer.net/api/v1/xml/projects/#{public_key}",
                       :status => status_code,
                       :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<project>\n  <access-secret nil=\"true\"></access-secret>\n  <created-at type=\"datetime\">2009-04-29T23:18:03Z</created-at>\n  <public-key>#{public_key}</public-key>\n <private-key>private_key_value</private-key>\n  <updated-at type=\"datetime\">2009-04-29T23:18:03Z</updated-at>\n</project>\n <short_uri>http://www.codometer.net/p/#{public_key}</short_uri>\n <community_uri>http://www.codometer.net/community/projects/#{public_key}</community_uri>\n <api-uri>http://www.codometer.net/api/v1/xml/projects/#{public_key}.xml</api-uri>\n <name>original_name</name>\n")

end

describe "Project" do
  after(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  describe "save" do
    context "with valid parameters" do
      context "when the public key has not been taken yet (or no key provided)" do
        before(:each) do
          register_create_uri
        end

        [ :public_key,
          :private_key,
          :short_uri,
          :community_uri,
          :api_uri].each do |method_name|
            it "sets the '#{method_name.to_s}'" do
              project = Codometer::Project.new
              project.send(method_name).should be_nil
              project.save
              project.send(method_name).should_not be_nil
            end
          end
      end

      context "when the public key has already been taken" do
        before(:each) do
          @updated_name = "different_name"
          @project = Codometer::Project.new(:public_key => "existing_public_key", :name => @updated_name)
          register_show_uri(@project.public_key, @updated_name)
          register_update_uri(@project.public_key, @updated_name)
          @project.stub!(:exists?).and_return(true)
          @project.save.should be_true
        end

        it "updates the value of 'name' for the project associated with the supplied public key" do
          @project.name.should == @updated_name
        end

        [ :public_key,
          :private_key,
          :short_uri,
          :community_uri,
          :name,
          :api_uri].each do |method_name|
            it "sets the '#{method_name.to_s}'" do
              @project.send(method_name).should_not be_nil
            end
          end
      end
    end

    context "with invalid parameters" do
      before(:each) do
          FakeWeb.register_uri( :post, "http://www.codometer.net/api/v1/xml/projects?project[public_key]=&project[name]=",
                                :status => ["422", "Unprocessable Entity"])
      end

      [:private_key].each do |method_name|
        it "does not set the '#{method_name.to_s}'" do
          project = Codometer::Project.new
          project.save.should be_false
          project.send(method_name).should be_nil
        end
      end
    end
  end

  context "delete" do
    before(:each) do
      @project = Project.new(:public_key => 'public_key_value')
      FakeWeb.register_uri( :delete, "http://www.codometer.net/api/v1/xml/projects/#{@project.public_key}",
                            :status => ["200", "Successful"],
                            :string =>  "")
    end

    it "returns true" do
      @project.delete.should be_true
    end
  end

  describe "exists?" do
    before(:each) do
      @public_key = "some_public_key"
    end

    context "when the specified public_key has been reserved already" do
      before(:each) do
        FakeWeb.register_uri(:get, "http://www.codometer.net/api/v1/xml/projects/#{@public_key}",
                             :status => ["200", "Ok"],
                             :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<project>\n  <access-secret nil=\"true\"></access-secret>\n  <created-at type=\"datetime\">2009-04-29T23:18:03Z</created-at>\n  <public-key>foofoolerue</public-key>\n <private-key>foobarbaz</private-key>\n  <updated-at type=\"datetime\">2009-04-29T23:18:03Z</updated-at>\n</project>\n <short_uri>http://www.codometer.net/p/foofoolerue</short_uri>\n <community_uri>http://www.codometer.net/community/projects/1</community_uri>\n <api-uri>http://www.codometer.net/api/v1/xml/projects/1.xml</api-uri>\n <name>original_name</name>\n")
      end

      it "returns true" do
        Project.new(:public_key => @public_key).exists?.should be_true
      end
    end

    context "when the public_key is not set" do
      it "returns false when the public key is nil" do
        Project.new.exists?.should be_false
      end

      it "returns false when the public key is an empty string" do
        Project.new(:public_key => "").exists?.should be_false
      end
    end

    context "when the specified public_key is available" do
      before(:each) do
        FakeWeb.register_uri(:get, "http://www.codometer.net/api/v1/xml/projects/#{@public_key}",
                             :status => ["404", "Not Found"],
                             :string =>  "")

      end

      it "returns false" do
        Project.new(:public_key => @public_key).exists?.should be_false
      end
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
    [:private_key, :api_uri, :community_uri, :short_uri].each do |attribute_name|
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

  describe "calling the class method" do
    describe "'find'" do
      context "and specifying a public_key which is already associated to a project on the site" do
        before(:each) do
          @public_key = "an_existing_public_key"
          register_show_uri(@public_key)
        end

        it "returns an initialized instance of the Project class" do
          expected_config =  {:an_existing_public_key=> [{:private_key=>"private_key_value"},
                                                         {:api_uri=>"http://www.codometer.net/api/v1/xml/projects/an_existing_public_key.xml"},
                                                         {:short_uri=>"http://www.codometer.net/p/an_existing_public_key"}
                                                        ]}
          Project.find(@public_key).to_config.should == expected_config
        end
      end

      context "and specifying a public_key which is not associated to any project on the site yet" do
        before(:each) do
          @public_key = "non_existant_public_key"
          register_show_uri(@public_key, "Some Name", ["404", "Not Found"])
        end

        it "returns nil" do
          Project.find(@public_key).should == nil
        end
      end
    end
  end
end
