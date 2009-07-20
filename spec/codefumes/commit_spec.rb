require File.dirname(__FILE__) + '/../spec_helper.rb'

def single_commit
<<-END_OF_COMMIT
<commit>
  <identifier>f3badd5624dfbcf5176f0471261731e1b92ce957</identifier>
  <author_name>John Doe</author_name>
  <author_email>jdoe@example.com</author_email>
  <committer_name>John Doe</committer_name>
  <committer_email>jdoe@example.com</committer_email>
  <short_message>Made command-line option for 'name' actually work</short_message>
  <message>
    Made command-line option for 'name' actually work
    - Commentd out hard-coded 'require' line used for testing
  </message>
  <parent_identifiers>9ddj48423jdsjds5176f0471261731e1b92ce957,3ewdjok23jdsjds5176f0471261731e1b92ce957,284djsksjfjsjds5176f0471261731e1b92ce957</parent_identifiers>
  <committed_at>Wed May 20 09:09:06 -0500 2009</committed_at>
  <authored_at>Wed May 20 09:09:06 -0500 2009</authored_at>
  <uploaded_at>2009-06-04 02:43:20 UTC</uploaded_at>
  <api_uri>http://localhost:3000/api/v1/commits/f3badd5624dfbcf5176f0471261731e1b92ce957.xml</api_uri>
  <line_additions>20</line_additions>
  <line_deletions>10</line_deletions>
  <line_total>30</line_total>
  <modified_file_count>2</modified_file_count>
</commit>
END_OF_COMMIT
end

def register_index_uri
  FakeWeb.register_uri(
    :get, "http://www.codefumes.com:80/api/v1/xml/projects/apk/commits",
    :status => ["200", "Ok"],
    :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<commits>\n#{single_commit}\n#{single_commit}\n#{single_commit}\n</commits>\n")
end

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
        FakeWeb.register_uri(
          :get, "http://www.codefumes.com:80/api/v1/xml/commits/f3badd5624dfbcf5176f0471261731e1b92ce957",
          :status => ["200", "Ok"],
          :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{single_commit}")
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
       :modified_file_count,
      ].each do |method_name|
        it "sets the '#{method_name.to_s}'" do
          @commit.send(method_name).should_not == nil
        end
      end
    end

    context "with a non-existant commit identifier" do
      before(:each) do
        @identifier = "non_existant_commit_identifier"
        FakeWeb.register_uri( :get, "http://www.codefumes.com:80/api/v1/xml/commits/#{@identifier}",
                              :status => ["404", "Not Found"])
      end

      it "returns nil" do
        Commit.find(@identifier).should == nil
      end
    end
  end

  describe "calling 'latest'" do
    before(:each) do
      @project_public_key = "apk"
    end

    context "with valid parameters" do
      before(:each) do
        FakeWeb.register_uri(
          :get, "http://www.codefumes.com:80/api/v1/xml/projects/#{@project_public_key}/commits/latest",
          :status => ["200", "Ok"],
          :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{single_commit}")
      end

      it "returns a commit object for the latest commit" do
        Commit.latest(@project_public_key).identifier.should == @identifier
      end
    end

    context "with invalid parameters" do
      before(:each) do
        FakeWeb.register_uri(
          :get, "http://www.codefumes.com:80/api/v1/xml/projects/#{@project_public_key}/commits/latest",
          :status => ["404", "Not Found"],
          :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{single_commit}")
      end

      it "returns nil" do
        Commit.latest(@project_public_key).should == nil
      end
    end
  end

  describe "calling 'latest_identifier'" do
    before(:each) do
      @project_public_key = "apk"
    end

    context "with valid parameters" do
      context "when the specified project has commits stored" do
        before(:each) do
          FakeWeb.register_uri(
            :get, "http://www.codefumes.com:80/api/v1/xml/projects/#{@project_public_key}/commits/latest",
            :status => ["200", "Ok"],
            :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{single_commit}")
        end

        it "returns the commit identifier of the latest commit" do
          Commit.latest_identifier(@project_public_key).should == @identifier
        end
      end

      context "when the specified project does not have any commits stored" do
        before(:each) do
          FakeWeb.register_uri(
            :get, "http://www.codefumes.com:80/api/v1/xml/projects/#{@project_public_key}/commits/latest",
            :status => ["404", "Not Found"],
            :string =>  "")
        end

        it "returns nil" do
          Commit.latest_identifier(@project_public_key).should == nil
        end
      end
    end

    context "with invalid parameters" do
      before(:each) do
        FakeWeb.register_uri(
          :get, "http://www.codefumes.com:80/api/v1/xml/projects/#{@project_public_key}/commits/latest",
          :status => ["404", "Not Found"],
          :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{single_commit}")
      end

      it "returns nil" do
        Commit.latest(@project_public_key).should == nil
      end
    end
  end

  describe "calling 'all'" do
    before(:each) do
      register_index_uri
      @project_public_key = "apk"
    end

    context "with valid parameters" do
      it "returns an array of commits" do
        Commit.all(@project_public_key).should have(3).items
      end
    end

    context "with invalid parameters" do
      before(:each) do
        FakeWeb.register_uri(
          :get, "http://www.codefumes.com:80/api/v1/xml/projects/apk/commits",
          :status => ["404", "Not Found"],
          :string =>  "")
      end

      it "returns nil" do
        Commit.all(@project_public_key).should == nil
      end
    end
  end

  describe "the convenience method" do
    before(:each) do
      @email = "jdoe@example.com"
      @name  = "John Doe"
      FakeWeb.register_uri(
        :get, "http://www.codefumes.com:80/api/v1/xml/commits/f3badd5624dfbcf5176f0471261731e1b92ce957",
        :status => ["200", "Ok"],
        :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{single_commit}")
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
end
