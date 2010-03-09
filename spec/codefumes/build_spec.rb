require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Build" do
  include CodeFumesServiceHelpers::Build

  after(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  before(:each) do
    setup_fixture_base
    setup_build_fixtures
    @build_params = { :public_key => @pub_key, :private_key => @priv_key,
                       :name => @build_name, :commit_identifier => @commit_identifier,
                       :started_at => @started_at, :state => @state}

    @build = Build.new(@build_params)
  end

  describe "save" do
    it "sets basic auth with the public and private key" do
      register_create_uri(["401", "Unauthorized"], "")
      basic_auth_params = {:username => @pub_key, :password => @priv_key}

      build_query = {:build => {:name => @build_name, :ended_at => nil, :started_at => @started_at, :state => @state}}
      Build.should_receive(:post).with("/projects/#{@project.public_key}/commits/#{@commit_identifier}/builds", :query => build_query, :basic_auth => basic_auth_params).and_return(mock("response", :code => 401))
      @build.save
    end

    context "with valid parameters" do
      before(:each) do
        register_create_uri(["201", "Created"])
      end

      it "sets a value for 'created_at'" do
        @build.created_at.should == nil
        @build.save.should == true
        @build.created_at.should_not == nil
      end

      it "sets a value for 'identifier'" do
        @build.identifier.should == nil
        @build.save.should == true
        @build.identifier.should_not == nil
      end
    end

    context "with Unauthorized response" do
      before(:each) do
        register_create_uri(["401", "Unauthorized"], "")
      end

      it "does not set 'created_at'" do
        @build.created_at.should == nil
        @build.save.should == false
        @build.created_at.should == nil
      end
    end

    context "when the build already exists on the server" do
      before(:each) do
        register_update_uri(["200", "OK"])
        @build = Build.new(@build_params.merge(:identifier => @build_identifier))
        Build.stub!(:find).and_return(@build)
      end

      it "updates the existing build" do
        mock_response = mock("Response", :code => 200).as_null_object
        @build.should_receive(:update).and_return(mock_response)
        @build.save
      end
    end
  end

  describe "find" do
    before(:each) do
      setup_fixture_base
      setup_build_fixtures
      @find_params = {:public_key => @pub_key,
                      :commit_identifier => @commit_identifier,
                      :identifier => @build_identifier}
    end

    it "returns an instance of Build when found" do
      register_show_uri(["200", "OK"])
      returned_object = Build.find(@find_params)
      returned_object.should  be_instance_of(Build)
      returned_object.state.should_not be_nil
    end

    it "returns nil when not found" do
      register_show_uri(["404", "Not found"])
      Build.find(@find_params).should be_nil
    end
  end

  describe "destroy" do
    before(:each) do
      setup_fixture_base
      setup_build_fixtures
      @build = Build.new(@build_params.merge(:identifier => @build_identifier))
    end

    it "returns true when the request returns a status of '200 Ok'" do
      register_delete_uri(["200", "OK"])
      @build.destroy.should be_true
    end

    it "returns false if the status is not '200 Ok'" do
      register_delete_uri(["500", "Internal Server Error"], "")
      @build.destroy.should be_false
    end
  end
end
