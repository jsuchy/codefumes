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
          ConfigFile.serialized[:projects].should include(@project.to_config)
        end
      end

      context "when passed an existing project" do
        before(:each) do
          ConfigFile.save_project(@project)
          @updated_project = Project.new(:public_key => @project.public_key, :private_key => "updated_private_key")
        end

        it "does not create a duplicate entry in the list of projects" do
          ConfigFile.serialized[:projects].should include(@project.to_config)
          ConfigFile.serialized[:projects].count.should == 1
          ConfigFile.save_project(@updated_project)
          ConfigFile.serialized[:projects].should include(@updated_project.to_config)
          ConfigFile.serialized.count.should == 1
        end
      end

      context "when several projects exist" do
        before(:each) do
          @project1 = Project.new(:public_key => "abcd", :private_key => "p1_private_key")
          @project2 = Project.new(:public_key => "efgh", :private_key => "p2_private_key")
          @project3 = Project.new(:public_key => "ijkl", :private_key => "p3_private_key")
          ConfigFile.save_project(@project1)
          ConfigFile.save_project(@project2)
          ConfigFile.save_project(@project3)
        end

        it "does not modify data pertaining to other projects" do
          ConfigFile.serialized[:projects].should include(@project1.to_config)
          ConfigFile.serialized[:projects].should include(@project2.to_config)
          ConfigFile.serialized[:projects].should include(@project3.to_config)
        end
      end
    end
  end
end
