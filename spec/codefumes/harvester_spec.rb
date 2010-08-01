require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#TODO: clean this up
include CodeFumesServiceHelpers::Shared
include CodeFumesServiceHelpers::ProjectHelpers

def raise_if_users_config_file
  if ConfigFile.path == File.expand_path('~/.codefumes_config')
    raise "Set a custom config file path"
  end
end

def delete_config_file
  unless ConfigFile.path == File.expand_path('~/.codefumes_config')
    File.delete(ConfigFile.path) if File.exist?(ConfigFile.path)
  end
end

describe Harvester do
  after(:all) do
    delete_config_file
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  before(:each) do
    raise_if_users_config_file
    setup_fixture_base
    register_create_uri #For project creation
    this_files_dir = File.dirname(__FILE__)
    @no_scm_path  = "#{this_files_dir}/../fixtures/sample_project_dirs/no_scm"
    @git_scm_path = "#{this_files_dir}/../fixtures/sample_project_dirs/git_repository"
  end

  describe "initialization" do
    context "with a path to a directory that is using the git SCM tool" do
      before(:each) do
        @repository = Grit::Repo.new(@git_scm_path)
        Grit::Repo.stub!(:new).with(File.expand_path(@git_scm_path)).and_return(@repository)
      end

      it "initializes a new Grit::Repo instance with the specified directory path" do
        Grit::Repo.should_receive(:new).with(File.expand_path(@git_scm_path)).and_return(@repository)
        Harvester.new(:path => @git_scm_path)
      end
    end

    context "with a path to a directory that is not using a supported SCM" do
      it "raises an UnsupportedScmToolError" do
        lambda {
          Harvester.new(:path => @no_scm_path)
        }.should raise_error(Errors::UnsupportedScmToolError)
      end
    end
  end

  describe "#path" do
    it "returns the full path to a project" do
      harvester = Harvester.new(:path => @git_scm_path)
      harvester.path.should == File.expand_path(@git_scm_path)
    end
  end

  describe "#publish_data!" do
    include CodeFumesServiceHelpers::CommitHelpers
    include CodeFumesServiceHelpers::ProjectHelpers

    before(:each) do
      delete_config_file
      register_latest_uri
      register_update_uri
      @harvester = Harvester.new(:path => @git_scm_path)
      @payload = mock("Payload instance", :save => true)
      Payload.stub!(:new).and_return(@payload)
    end

    it "saves the Payload to the website" do
      pending "Need to figure out a better way to test this..."
      @payload.should_receive(:save).and_return(true)
      @harvester.publish_data!
    end

    it "updates the config file's project information" do
      pending "Need to figure out a better way to test this..."
      ConfigFile.should_receive(:save_project)
      @harvester.publish_data!
    end
  end
end
