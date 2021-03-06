require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "API::Payload" do
  include CodeFumesServiceHelpers::PayloadHelpers

  after(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  before(:each) do
    setup_fixture_base
    @payload = Payload.new(@project, @commit_data)
    @payload_query = {:payload => {:commits => @commit_data}}
    @basic_auth_params = {:username => @pub_key, :password => @priv_key}
  end

  describe "#save" do
    it "sets basic auth with the public and private key" do
      register_create_uri(["401", "Unauthorized"], "")
      API.should_receive(:post).with("/projects/#{@project.public_key}/payloads", :query => @payload_query, :basic_auth => @basic_auth_params).and_return(mock("response", :code => 401))
      @payload.save
    end

    context "with valid parameters" do
      before(:each) do
        register_create_uri(["201", "Created"])
      end

      it "sets a value for 'created_at'" do
        @payload.created_at.should == nil
        @payload.save.should == true
        @payload.created_at.should_not == nil
      end
    end

    context "with Unauthorized response" do
      before(:each) do
        register_create_uri(["401", "Unauthorized"], "")
      end

      it "does not set 'created_at'" do
        @payload.created_at.should == nil
        @payload.save.should == false
        @payload.created_at.should == nil
      end
    end

    context "when the payload does not have any commit information" do
      before(:each) do
        @payload = Payload.new(@project, "")
      end

      it "returns true without attempting to save to the site" do
        Payload.should_not_receive(:post)
        @payload.save.should == true
      end

      it "does not set the value of created_at" do
        @payload.save
        @payload.created_at.should == nil
      end
    end

    context "with invalid parameters" do
      before(:each) do
        register_create_uri
      end

      it "does not set a value for 'created_at'" do
        @payload.save.should == false
        @payload.created_at.should == nil
      end
    end
  end

  describe "#prepare" do
    it "is compatible with the entity returned from SourceControl#payload_between" do
      git_repo_path = File.expand_path(File.dirname(__FILE__) + '/../../fixtures/sample_project_dirs/git_repository')
      repository = SourceControl.new(git_repo_path)
      project = Project.new('public_key', 'private_key')
      lambda {
        pl = Payload.prepare(project, repository.payload_between('HEAD^', 'HEAD'))
        pl.length.should == 1
      }.should_not raise_error
    end

    context "when supplying nil commit information" do
      it "returns an empty array" do
        Payload.prepare(@project, nil).should == []
      end
    end

    context "when supplying an empty Hash" do
      it "returns an empty array" do
        Payload.prepare(@project, {}).should == []
      end
    end

    context "when supplying a hash with less than 4,000 characters" do
      before(:each) do
        single_commit_ex =  {:identifier => "92dd08477f0ca144ee0f12ba083760dd810760a2_000"}
        commit_count = 4000 / single_commit_ex.to_s.length
        commits = commit_count.times.map do |index|
          {:identifier => "92dd08477f0ca144ee0f12ba083760dd810760a2_#{index}"}
        end
        @prepared = Payload.prepare(@project, {:commits => commits})
      end

      it "returns an Array with a single payload element" do
        @prepared.should be_instance_of(Array)
        @prepared.size.should == 1
        @prepared.first.should be_instance_of(Payload)
      end

      it "associated the specified project with all generated payloads" do
        @prepared.each do |payload|
          payload.project.should == @project
        end
      end
    end

    context "when supplying a hash with approximately 15,000 characters" do
      before(:each) do
        single_commit_ex =  {:identifier => "92dd08477f0ca144ee0f12ba083760dd810760a2_000"}
        commit_count = 15000 / single_commit_ex.to_s.length + 1
        commits = commit_count.times.map do |index|
          {:identifier => "92dd08477f0ca144ee0f12ba083760dd810760a2_#{index}"}
        end
        raw_payload = {:commits => commits}
        @prepared = Payload.prepare(@project, raw_payload)
      end

      it "returns an Array with a four payload elements" do
        @prepared.should be_instance_of(Array)
        @prepared.size.should == 4
        all_are_payloads = @prepared.all? {|chunk| chunk.instance_of?(Payload)}
        all_are_payloads.should == true
      end

      it "associated the specified project with all generated payloads" do
        @prepared.each do |payload|
          payload.project.should == @project
        end
      end
    end
  end
end
