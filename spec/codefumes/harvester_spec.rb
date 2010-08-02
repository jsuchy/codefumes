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


  let(:no_scm_path) {"#{File.dirname(__FILE__)}/../fixtures/sample_project_dirs/no_scm"}
  let(:git_scm_path) {"#{File.dirname(__FILE__)}/../fixtures/sample_project_dirs/git_repository"}


  before(:each) do
    raise_if_users_config_file
    setup_fixture_base
    register_create_uri #For project creation
    @repository = Grit::Repo.new(git_scm_path)
  end

  describe "#new" do
    context "with a path to a directory that is using git" do
      before(:each) do
        Grit::Repo.stub!(:new).with(File.expand_path(git_scm_path)).and_return(@repository)
      end

      it "initializes a new Grit::Repo instance with the specified directory path" do
        Grit::Repo.should_receive(:new).with(File.expand_path(git_scm_path)).and_return(@repository)
        Harvester.new(:path => git_scm_path)
      end
    end

    context "with a path to a directory that is not using a supported SCM" do
      it "raises an UnsupportedScmToolError" do
        lambda {
          Harvester.new(:path => no_scm_path)
        }.should raise_error(Errors::UnsupportedScmToolError)
      end
    end

    context "when specifying the public/private keys" do
      let(:public_key) {@pub_key}
      let(:private_key) {@priv_key}

      it "ignores the configuration saved in the underlying repository" do
        register_show_uri
        @repository.should_not_receive(:public_key)
        @repository.should_not_receive(:private__key)
        lambda {Harvester.new(:public_key => public_key, :private_key => private_key)}
      end

      context "if the specified project is not found on the server" do
        before(:each) {register_show_uri(["404", "Not found"])}

        it "raises an UnknownProjectError" do
          lambda {
            Harvester.new(:public_key => public_key, :private_key => private_key)
          }.should raise_error(Errors::UnknownProjectError)
        end

        it "does not attempt to create a new project on the CodeFumes site" do
          Project.should_not_receive(:create)
          lambda {Harvester.new(:public_key => public_key, :private_key => private_key)}
        end
      end
    end
  end

  describe "#path" do
    it "returns the full path to a project" do
      harvester = Harvester.new(:path => git_scm_path)
      harvester.path.should == File.expand_path(git_scm_path)
    end
  end

  describe "#publish_data!" do
    include CodeFumesServiceHelpers::CommitHelpers
    include CodeFumesServiceHelpers::ProjectHelpers

    before(:each) do
      delete_config_file
      register_latest_uri
      register_update_uri
      @harvester = Harvester.new(:path => git_scm_path)
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
