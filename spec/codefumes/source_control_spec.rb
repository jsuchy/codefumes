require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SourceControl do
  after(:each) do
    SourceControl.new(GIT_FIXTURE_REPO_PATH).unlink_from_codefumes!
    unless ConfigFile.path == File.expand_path('~/.codefumes_config')
      File.delete(ConfigFile.path) if File.exists?(ConfigFile.path)
    end
  end

  describe "creation" do
    context "with a path to a directory that is not a git repository" do
      it "raises an error" do
        invalid_path = File.dirname(__FILE__)
        lambda {SourceControl.new(invalid_path)}.should raise_error(Errors::UnsupportedScmToolError)
      end
    end
  end

  describe "#supported_systems" do
    it "includes :git" do
      SourceControl.supported_systems.should include(:git)
    end
  end

  describe "#supported_system?" do
    SourceControl.supported_systems.each do |scm_tool|
      it "returns true for the string '#{scm_tool.to_s}'" do
        SourceControl.supported_system?(scm_tool.to_s)
      end

      it "returns true for the symbol ':#{scm_tool.to_s}'" do
        SourceControl.supported_system?(scm_tool.to_sym)
      end
    end
  end

  describe "#initial_commit_identifier" do
    before(:each) do
      git_repo_path = File.expand_path(File.dirname(__FILE__) + '/../fixtures/sample_project_dirs/git_repository')
      @repository = SourceControl.new(git_repo_path)
    end

    it "returns the identifer (sha/commit #) of the first commit" do
      @repository.initial_commit_identifier.should == "a8b3e73fc5e4bc46bbdf5c1cab38cb2ce47ba2d0"
    end
  end

  describe "#payload_between" do
    before(:each) do
      git_repo_path = File.expand_path(File.dirname(__FILE__) + '/../fixtures/sample_project_dirs/git_repository')
      @repository = SourceControl.new(git_repo_path)
    end

    it "returns a Hash containing the key ':commits'" do
      @repository.payload_between.keys.should include(:commits)
    end

    it "is aliased to 'payload'" do
      @repository.payload_between.keys.should == @repository.payload.keys
      # FIXME: Improve this...not a complete test. Object ids getting in the way
      @repository.payload_between[:commits].each_with_index do |commit, index|
        commit[:identifier].should == @repository.payload[:commits][index][:identifier]
      end
    end

    it "returns the commits in the same order a standard 'log view' of the repository would" do
      first_commit = @repository.payload_between[:commits].last
      first_commit[:identifier].should == "a8b3e73fc5e4bc46bbdf5c1cab38cb2ce47ba2d0"
    end

    context "the ':commits' key returned" do
      context "contains a list of data for each commit" do
        before(:each) do
          @first_commit = @repository.payload_between[:commits].last
        end

        it "contains 'id', which is the 'sha' of the commit" do
          @first_commit[:identifier].should == "a8b3e73fc5e4bc46bbdf5c1cab38cb2ce47ba2d0"
        end

        it "contains 'author', which points to the 'email' & the 'name' of the commit (in a Hash)" do
          @first_commit[:author_email].should == "tkersten@obtiva.com"
          @first_commit[:author_name].should == "Tom Kersten"
        end

        it "contains 'committer', which points to the 'email' & the 'name' of the commit (in a Hash)" do
          @first_commit[:committer_email].should == "tkersten@obtiva.com"
          @first_commit[:committer_name].should == "Tom Kersten"
        end

        it "contains 'message', which holds the full message of the commit" do
          @first_commit[:message].should == "Initial commit with description of directory"
        end

        it "contains 'short_message', which holds the first line of the message of the commit" do
          @first_commit[:short_message].should == "Initial commit with description of directory"
        end

        it "contains 'committed_date' of the commit" do
          @first_commit[:committed_at].should == Chronic.parse("Sat May 09 08:52:14 -0500 2009")
        end

        it "contains 'authored_date' of the commit" do
          @first_commit[:authored_at].should == Chronic.parse("Sat May 09 08:52:14 -0500 2009")
        end

        it "contains 'parent_commits' of the commit" do
          @first_commit[:parent_identifiers].should_not be_nil
        end

        it "contains a 'line_additions' key" do
          @first_commit[:line_additions].should_not be_nil
        end

        it "contains an 'line_deletions' key" do
          @first_commit[:line_deletions].should_not be_nil
        end

        it "contains an 'line_total' key" do
          @first_commit[:line_total].should_not be_nil
        end

        it "contains a 'affected_file_count' key" do
          @first_commit[:affected_file_count].should_not be_nil
        end
      end
    end

    context "when 'from' is specified but the value is nil" do
      it "defaults to the initial commit identifier of the repository" do
        @repository.should_receive(:commits_between).with("a8b3e73fc5e4bc46bbdf5c1cab38cb2ce47ba2d0", anything()).and_return([])
        @repository.payload_between(nil, "something")
      end
    end

    context "when 'to' is specified but the value is nil" do
      it "defaults to the 'HEAD' commit identifier of the repository" do
        @repository.should_receive(:commits_between).with(anything(), "HEAD").and_return([])
        @repository.payload_between("something", nil)
      end
    end

    context "when there is no new information to send up" do
      it "returns an empty object" do
        @repository.payload_between("HEAD", "HEAD").should be_empty
      end
    end
  end

  describe "#public_key=" do
    before(:each) do
      git_repo_path = File.expand_path(File.dirname(__FILE__) + '/../fixtures/sample_project_dirs/git_repository')
      @public_key = "public_key_specified"
      @repository = SourceControl.new(git_repo_path)
      @project = Project.new(:public_key => @public_key)
    end

    it "stores the supplied public key in the SCM tool's repository-specific configuration" do
      @repository.store_public_key(@public_key)
      @repository.public_key.should == @public_key
    end
  end

  describe "#public_key" do
    before(:each) do
      @public_key = "original_value"
      git_repo_path = File.expand_path(File.dirname(__FILE__) + '/../fixtures/sample_project_dirs/git_repository')
      @repository = SourceControl.new(git_repo_path)
      @repository.store_public_key(@public_key)
    end

    it "returns the current value of 'codometer.public_key' from the repository-specific configuration" do
      @repository.public_key.should == @public_key
    end
  end

  describe "#local_commit_identifier" do
    before(:each) do
      git_repo_path = File.expand_path(File.dirname(__FILE__) + '/../fixtures/sample_project_dirs/git_repository')
      @repository = SourceControl.new(git_repo_path)
    end

    it "returns the current commit identifier for the local repository" do
      @repository.local_commit_identifier.should == "7dc0e73fea4625204b7c1e6a48e9a57025be4d7e"
    end
  end

  describe "#path" do
    before(:each) do
      @git_repo_path = File.expand_path(File.dirname(__FILE__) + '/../fixtures/sample_project_dirs/git_repository')
      @repository = SourceControl.new(@git_repo_path)
    end

    it "returns the full path to the .git directory of the repository" do
      @repository.path.should == @git_repo_path + '/.git'
    end
  end
end
