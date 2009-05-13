require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "ConfigFile" do
  context "class method" do
    describe "calling 'path'" do
      it "returns a the full path to a dotfile named '.codometer_config' in the user's home directory" do
        ConfigFile.path.should == File.expand_path('~/.codometer_config')
      end

      context "when the file does not exist" do
        before(:each) do
          @file_path = ConfigFile.path
          File.delete(@file_path) if File.exist?(ConfigFile.path)
        end
      end
    end

    describe "'save_project'" do
      before(:each) do
        @project = Project.new(:public_key => 'ghKly', :private_key => 'a_private_key_here')
      end

      context "when passed a new project" do
        it "creates the config file if it did not exist already" do
          File.delete(ConfigFile.path) if File.exist?(ConfigFile.path)
          File.exist?(ConfigFile.path).should be_false
          ConfigFile.save_project(@project)
          File.exist?(ConfigFile.path).should be_true
        end

        it "adds the supplied project's public key as a new entry under 'projects'" do
          ConfigFile.save_project(@project)
          updated_config = ConfigFile.serialized
          updated_config[:projects].should include(@project.to_config)
        end
      end

      context "when passed an existing project" do
        it "does not create a duplicate entry in the list of projects"
        it "updates the private_key of the existing entry"
      end

      context "when several projects exist" do
        it "does not modify data pertaining to other projects"
      end
    end
  end
end
