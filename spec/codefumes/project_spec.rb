require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Project" do
  include CodeFumesServiceHelpers::Project

  before(:each) do
    setup_fixture_base
  end

  after(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  describe "#create" do
    context "when successful" do
      before(:each) do
        register_no_param_create_uri
      end

      it "returns an instance of the Project class" do
        Project.create.should be_instance_of(Project)
      end

      [:public_key,
       :private_key,
       :short_uri,
       :community_uri,
       :api_uri].each do |method_name|
         it "sets the '#{method_name.to_s}'" do
           project = Project.create
           project.send(method_name).should_not be_nil
         end
       end
    end

    context "when unsuccessful" do
      before(:each) do
        register_no_param_create_uri(["404", "Not found"])
      end

      specify {Project.create.should be_false}
    end
  end

  describe "#save" do
    context "with valid parameters" do
      it "sets basic auth with the public and private key" do
        register_update_uri
        Project.should_receive(:put).with("/projects/#{@project.public_key}", :query => anything(), :basic_auth => {:username => @project.public_key, :password => @project.private_key}).and_return(mock("response", :code => 401))
        @project.save
      end

      context "and the response is '200 Ok'" do
        before(:each) do
          register_update_uri
          @project.name = @updated_name
          @project.save.should be_true
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

      context "and the response is '401 Unauthorized'" do
        it "returns false" do
          @project.name = @updated_name
          register_update_uri(["401", "Unauthorized"])
          @project.save.should be_false
        end
      end
    end

    context "with invalid parameters" do
      before(:each) do
        register_show_uri(["404", "Not found"], "")
        register_no_param_create_uri(["422", "Unprocessable Entity"], "")
      end

      it "returns false" do
        Project.create.should be_false
      end
    end
  end

  context "delete" do
    before(:each) do
      FakeWeb.register_uri(:delete, @authd_project_api_uri, :status => ["200", "Successful"], :body   => "")
    end

    it "sets basic auth with the public and private key" do
      Project.should_receive(:delete).with("/projects/#{@project.public_key}", :basic_auth => {:username => @project.public_key, :password => @project.private_key}).and_return(mock("response", :code => 401))
      @project.delete
    end

    context "without a private key specified" do
      it "raises an InsufficientCredentials error" do
        lambda {Project.new('public_key').delete}.should raise_error(Errors::InsufficientCredentials)
      end
    end

    context "without a public key specified" do
      it "raises an InsufficientCredentials error" do
        lambda {Project.new(nil, :private_key => 'private_key').delete}.should raise_error(Errors::InsufficientCredentials)
      end
    end

    context "with Sucessful response" do
      it "returns true" do
        @project.delete.should be_true
      end
    end

    context "with Unauthorized response" do
      it "returns false when invalid Unauthorized response is received" do
        register_delete_uri(["401", "Unauthorized"], "")
        @project.delete.should be_false
      end
    end
  end

  describe "exists?" do
    context "when the specified public_key has been reserved already" do
      it "returns true" do
        register_show_uri
        Project.new(@pub_key).exists?.should be_true
      end
    end

    context "when the public_key is not set" do
      it "returns false when the public key is nil" do
        Project.new.exists?.should be_false
      end

      it "returns false when the public key is an empty string" do
        Project.new("").exists?.should be_false
      end
    end

    context "when the specified public_key is available" do
      before(:each) do
        register_show_uri(["404", "Not Found"], "")
      end

      it "returns false" do
        Project.new(@pub_key).exists?.should be_false
      end
    end
  end

  describe "to_config" do
    before(:each) do
      register_show_uri(["404", "Not Found"], "")
      register_create_uri
      @project = Project.create(@project_name)
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

    it "doesn't include the private_key in the hash if it is nil" do
      public_key = "key_to_happiness"
      Project.new(public_key).to_config[public_key.to_sym].should_not have_key(:private_key)
    end
  end

  describe "claim" do
    before(:each) do
      @project = Project.new('public_key_value', :private_key => 'private_key_value')
      @api_key = "USERS_API_KEY"
      ConfigFile.stub!(:credentials).and_return({:api_key => @api_key})
    end

    it "delegates the request to the Claim class" do
      Claim.should_receive(:create).with(@project, @api_key)
      @project.claim
    end
  end

  describe "protected attributes" do
    [:api_uri, :community_uri, :short_uri].each do |attribute_name|
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
    let(:key_specified) {"public_key"}
    let(:name_specified) {"project_name"}
    let(:project) {Project.new(key_specified, :name => name_specified)}

    specify {project.public_key.should == key_specified}
    specify {project.name.should == name_specified}
  end

  describe "calling the class method" do
    describe "'find'" do
      context "and specifying a public_key which is already associated to a project on the site" do
        it "returns an initialized instance of the Project class" do
          register_show_uri
          expected_config = {
                              @pub_key.to_sym =>
                                {
                                  :private_key=>"private_key_value",
                                  :api_uri=>"http://codefumes.com/api/v1/xml/projects/#{@pub_key}.xml",
                                  :short_uri=>"http://codefumes.com/p/#{@pub_key}"
                                }
                            }
          Project.find(@pub_key).to_config.should == expected_config
        end
      end

      context "and specifying a public_key which is not associated to any project on the site yet" do
        before(:each) do
          register_show_uri(["404", "Not Found"], "")
        end

        it "returns nil" do
          Project.find(@pub_key).should == nil
        end
      end
    end
  end

  describe "#reinitialize_from_hash!" do
    let(:option_keys) {[:name, :public_key, :private_key, :short_uri, :community_uri, :api_uri, :build_status]}

    it "supports a Hash with Strings as keys" do
      params = option_keys.inject({}) {|option_params,key| option_params.merge(key.to_s => key.to_s)}
      project = Project.new.reinitialize_from_hash!(params)
      option_keys.each do |attr_name|
        project.send(attr_name).should == attr_name.to_s
      end
    end

    it "supports a Hash with Symbols as keys" do
      params = option_keys.inject({}) {|option_params,key| option_params.merge(key.to_sym => key.to_s)}
      project = Project.new.reinitialize_from_hash!(params)
      option_keys.each do |attr_name|
        project.send(attr_name.to_sym).should == attr_name.to_s
      end
    end
  end
end
