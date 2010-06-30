require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include CodeFumesServiceHelpers::Shared

describe Harvester do
  before(:each) do
    setup_fixture_base
    this_files_dir = File.dirname(__FILE__)
    @no_scm_path  = "#{this_files_dir}/../fixtures/sample_project_dirs/no_scm"
    @git_scm_path = "#{this_files_dir}/../fixtures/sample_project_dirs/git_repository"
  end

  describe "initialization" do
    context "with a path to a directory that is using the git SCM tool" do
      before(:each) do
        @repository = Grit::Repo.new(@git_scm_path)
        Grit::Repo.stub!(:new).with(File.expand_path(@git_scm_path)).and_return(@repository)
        Project.stub!(:new).and_return(@project)
      end

      def initialize_with_git
        Harvester.new(:path => @git_scm_path)
      end

      it "creates a new Grit::Repo instance" do
        Grit::Repo.should_receive(:new).with(File.expand_path(@git_scm_path)).and_return(@repository)
        initialize_with_git
      end

      it "creates a new Project instance" do
        Project.should_receive(:new).and_return(@project)
        initialize_with_git
      end
    end

    context "with a path to a directory that is not using a supported SCM" do
      it "raises an error" do
        lambda {Harvester.new(:path => @no_scm_path)}.should raise_error(Errors::UnsupportedScmToolError)
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

    before(:each) do
      register_latest_uri
      Project.should_receive(:new).and_return(@project)
      @harvester = Harvester.new(:path => @git_scm_path)
      @payload = mock("Payload instance", :save => true)
      Payload.stub!(:new).and_return(@payload)
      @project.stub!(:save).and_return(true)
    end

    it "saves the Payload to the website" do
      pending "Need to figure out a better way to test this..."
      @payload.should_receive(:save).and_return(true)
      @harvester.publish_data!
    end

    it "updates the config file's project information" do
      ConfigFile.should_receive(:save_project)
      @harvester.publish_data!
    end
  end
end
