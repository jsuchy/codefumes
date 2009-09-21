require File.dirname(__FILE__) + '/../spec_helper.rb'

include CodeFumesServiceStubs

describe "Commit" do
  before(:all) do
    @identifier = "f3badd5624dfbcf5176f0471261731e1b92ce957"
    FakeWeb.allow_net_connect = false
  end

  after(:all) do
    FakeWeb.clean_registry
  end

  describe "find" do
    context "with a valid commit identifier" do
      before(:each) do
        stub_codefumes_uri("commits/#{@identifier}", ["200", "Ok"], single_commit)
        @commit = Commit.find(@identifier)
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
        @identifier = "non_existant_commit_identifier"
        stub_codefumes_uri("commits/#{@identifier}", ["404", "Not Found"], "")
      end

      it "returns nil" do
        Commit.find(@identifier).should == nil
      end
    end
  end

  describe "calling 'latest'" do
    before(:each) do
      @project_public_key = "apk"
      @request_uri = "projects/#{@project_public_key}/commits/latest"
    end

    context "with valid parameters" do
      before(:each) do
        stub_codefumes_uri(@request_uri, ["200", "Ok"], single_commit)
      end

      it "returns a commit object for the latest commit" do
        Commit.latest(@project_public_key).identifier.should == @identifier
      end
    end

    context "with invalid parameters" do
      before(:each) do
        stub_codefumes_uri(@request_uri, ["404", "Not Found"], single_commit)
      end

      it "returns nil" do
        Commit.latest(@project_public_key).should == nil
      end
    end
  end

  describe "calling 'latest_identifier'" do
    before(:each) do
      @project_public_key = "apk"
      @request_uri = "projects/#{@project_public_key}/commits/latest"
    end

    context "with valid parameters" do
      context "when the specified project has commits stored" do
        it "returns the commit identifier of the latest commit" do
          stub_codefumes_uri(@request_uri, ["200", "Ok"], single_commit)
          Commit.latest_identifier(@project_public_key).should == @identifier
        end
      end

      context "when the specified project does not have any commits stored" do
        it "returns nil" do
          stub_codefumes_uri(@request_uri, ["404", "Not Found"], single_commit)
          Commit.latest_identifier(@project_public_key).should == nil
        end
      end
    end

    context "with invalid parameters" do
      it "returns nil" do
        stub_codefumes_uri(@request_uri, ["404", "Not Found"], single_commit)
        Commit.latest(@project_public_key).should == nil
      end
    end
  end

  describe "calling 'all'" do
    before(:each) do
      @project_public_key = "apk"
    end

    context "with valid parameters" do
      it "returns an array of commits" do
        register_index_uri
        Commit.all(@project_public_key).should have(3).items
      end
    end

    context "with invalid parameters" do
      it "returns nil" do
        stub_codefumes_uri("projects/apk/commits", ["404", "Not Found"], single_commit)
        Commit.all(@project_public_key).should == nil
      end
    end
  end

  describe "the convenience method" do
    before(:each) do
      stub_codefumes_uri("commits/f3badd5624dfbcf5176f0471261731e1b92ce957", ["200", "Ok"], single_commit)
      @email = "jdoe@example.com"
      @name  = "John Doe"
      @commit = Commit.find(@identifier)
    end

    describe "author" do
      it "returns a concatenated string containing the author's name & email" do
        @commit.author.should =~ /#{@name}/
        @commit.author.should =~ /#{@email}/
      end
    end

    describe "committer" do
      it "returns a concatenated string containing the author's name & email" do
        @commit.committer.should =~ /#{@name}/
        @commit.committer.should =~ /#{@email}/
      end
    end
  end

  describe "accessing custom metrics" do
    before(:each) do
      @project_public_key = "apk"
    end

    context "when the commit does not have any custom attributes" do
      before(:each) do
        stub_codefumes_uri("projects/#{@project_public_key}/commits/latest", ["200", "Ok"], single_commit)
      end

      it "returns an empty Hash" do
        Commit.latest(@project_public_key).custom_attributes.should == {}
      end
    end

    context "when the commit has defined custom attributes" do
      before(:each) do
        commit_content = single_commit(:include_custom_attributes => true)
        stub_codefumes_uri("projects/#{@project_public_key}/commits/latest", ["200", "Ok"], commit_content)
      end

      it "returns a Hash of key-value pairs (attribute_name -> attribute_value)" do
        Commit.latest(@project_public_key).custom_attributes.should be_instance_of(Hash)
        Commit.latest(@project_public_key).custom_attributes[:coverage].should == "83"
        Commit.latest(@project_public_key).custom_attributes[:random_attribute].should == "1"
        Commit.latest(@project_public_key).custom_attributes.size.should == 2
      end
    end
  end
end
