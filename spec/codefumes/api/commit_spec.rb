require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "API::Commit" do
  include CodeFumesServiceHelpers::CommitHelpers

  before(:all) do
    FakeWeb.allow_net_connect = false

    @project_name = "Project_Name(tm)"
    @pub_key = 'public_key_value'
    @priv_key = 'private_key_value'
    @anonymous_base_uri = "http://codefumes.com/api/v1/xml"
    @authenticated_base_uri = "http://#{@pub_key}:#{@priv_key}@codefumes.com/api/v1/xml/projects"
    @project = Project.new(@pub_key, :private_key => @priv_key, :name => @project_name)
    @authd_project_api_uri = "#{@authenticated_base_uri}/projects/#{@pub_key}"
    @anon_project_api_uri  = "#{@anonymous_base_uri}/projects/#{@pub_key}"
    @basic_auth_params = {:username => @pub_key, :password => @priv_key}
    @identifier = "f3badd5624dfbcf5176f0471261731e1b92ce957"
  end

  after(:all) do
    FakeWeb.clean_registry
  end

  describe "#id" do
    it "returns the value of #identifier" do
      Commit.new(@project, @identifier).id.should == @identifier
    end
  end

  describe "#sha" do
    it "returns the value of #identifier" do
      Commit.new(@project, @identifier).sha.should == @identifier
    end
  end

  describe "#find" do
    context "with a valid commit identifier" do
      before(:each) do
        register_find_uri
        @commit = Commit.find(@project, @identifier)
      end

      [:identifier,
       :author_email,
       :author_name,
       :committer_name,
       :committer_email,
       :short_message,
       :message,
       :committed_at,
       :authored_at,
       :uploaded_at,
       :api_uri,
       :parent_identifiers,
       :line_additions,
       :line_deletions,
       :line_total,
       :affected_file_count,
      ].each do |method_name|
        it "sets the '#{method_name.to_s}'" do
          @commit.send(method_name).should_not == nil
        end
      end
    end

    context "with a non-existant commit identifier" do
      before(:each) do
        register_find_uri(["404", "Not Found"], "")
      end

      it "returns nil" do
        Commit.find(@project, @identifier).should == nil
      end
    end
  end

  describe "#latest" do
    context "with valid parameters" do
      it "returns a commit object for the latest commit" do
        register_latest_uri
        Commit.latest(@project).identifier.should == @identifier
      end
    end

    context "with invalid parameters" do
      it "returns nil" do
        register_latest_uri(["404", "Not Found"], "")
        Commit.latest(@project).should == nil
      end
    end
  end

  describe "#latest_identifier" do
    context "with valid parameters" do
      context "when the specified project has commits stored" do
        it "returns the commit identifier of the latest commit" do
          register_latest_uri
          Commit.latest_identifier(@project).should == @identifier
        end
      end

      context "when the specified project does not have any commits stored" do
        it "returns nil" do
          register_latest_uri(["404", "Not Found"], "")
          Commit.latest_identifier(@project).should == nil
        end
      end
    end

    context "with invalid parameters" do
      it "returns nil" do
        register_latest_uri(["404", "Not Found"], "")
        Commit.latest(@project).should == nil
      end
    end
  end

  describe "#all" do
    context "with valid parameters" do
      it "returns an array of commits" do
        register_index_uri
        Commit.all(@project).should have(3).items
      end
    end

    context "with invalid parameters" do
      it "returns nil" do
        register_index_uri(["404", "Not Found"], "")
        Commit.all(@project).should == nil
      end
    end
  end

  describe "the convenience method" do
    before(:each) do
      register_find_uri
      @email = "jdoe@example.com"
      @name  = "John Doe"
      @commit = Commit.find(@project, @identifier)
    end

    describe "#author" do
      it "returns a concatenated string containing the author's name & email" do
        @commit.author.should =~ /#{@name}/
        @commit.author.should =~ /#{@email}/
      end
    end

    describe "#committer" do
      it "returns a concatenated string containing the author's name & email" do
        @commit.committer.should =~ /#{@name}/
        @commit.committer.should =~ /#{@email}/
      end
    end
  end

  describe "accessing custom metrics" do
    context "when the commit does not have any custom attributes" do
      before(:each) do
        register_latest_uri
      end

      it "returns an empty Hash" do
        Commit.latest(@project).custom_attributes.should == {}
      end
    end

    context "when the commit has defined custom attributes" do
      before(:each) do
        register_latest_uri(["200", "Ok"], fixtures[:commit_with_custom_attrs])
        @commit = Commit.latest(@project)
      end

      it "returns a Hash of key-value pairs (attribute_name -> attribute_value)" do
        @commit.custom_attributes.should be_instance_of(Hash)
        @commit.custom_attributes[:coverage].should == "83"
        @commit.custom_attributes[:random_attribute].should == "1"
        @commit.custom_attributes.size.should == 2
      end
    end
  end

  describe "builds" do
    let(:project) {@project}
    let(:commit) {Commit.latest(project)}

    before(:each) do
      register_latest_uri
    end

    context "when no builds are associated with the commit" do
      it "returns an empty array" do
        register_builds_uri(["200", "Ok"], fixtures[:no_builds])
        commit.builds.should == []
      end
    end

    context "when builds are associated with the commit" do
      it "returns an array of Build objects" do
        register_builds_uri
        commit.builds.each {|b| b.should be_instance_of(Build)}
      end
    end
  end
end
