require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "ConfigFile" do
  before(:each) do
    @project = Project.new(:public_key => 'public_key_value', :private_key => 'private_key_value')
  end

  after(:all) do
    unless ConfigFile.path == File.expand_path('~/.codefumes_config')
      File.delete(ConfigFile.path) if File.exist?(ConfigFile.path)
    end
  end

  describe "calling 'path'" do
    before(:each) do
      @original_path = ENV['CODEFUMES_CONFIG_FILE']
    end

    after(:all) do
      ENV['CODEFUMES_CONFIG_FILE'] = @original_path
    end

    it "returns a default value of the full path to a dotfile named '.codefumes_config' in the user's home directory" do
      ENV['CODEFUMES_CONFIG_FILE'] = nil
      ConfigFile.path.should == File.expand_path('~/.codefumes_config')
    end
  end

  describe "calling 'save_project'" do
    after(:all) do
      File.delete(ConfigFile.path) if File.exist?(ConfigFile.path)
    end

    context "when passed a new project" do
      it "creates the config file if it did not exist already" do
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
        @project1 = Project.new(:public_key => :p1_pub_value, :private_key => "p1_private_key")
        @project2 = Project.new(:public_key => :p2_pub_value, :private_key => "p2_private_key")
        @project3 = Project.new(:public_key => :p3_pub_value, :private_key => "p3_private_key")
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

  describe "calling 'delete_project'" do
    context "when the project entry exists in the file" do
      before(:each) do
        @project1 = Project.new(:public_key => "p1_pub_value", :private_key => "p1_private_key")
        @project2 = Project.new(:public_key => "p2_pub_value", :private_key => "p2_private_key")
        @project3 = Project.new(:public_key => "p3_pub_value", :private_key => "p3_private_key")
        ConfigFile.save_project(@project1)
        ConfigFile.save_project(@project2)
        ConfigFile.save_project(@project3)
        ConfigFile.delete_project(@project2)
      end

      it "removes the entry for the supplied project from the file" do
        ConfigFile.serialized[:projects].should_not include(@project2.to_config)
      end

      xit "does not affect other project entries" do
        ConfigFile.serialized[:projects].should include(@project1.to_config)
        ConfigFile.serialized[:projects].should include(@project3.to_config)
      end
    end

    context "when the project entry does not exist in the file" do
      before(:each) do
        @project = Project.new(:public_key => "p1_pub_nonexist_value", :private_key => "p1_private_key")
      end

      it "does not raise an error" do
        lambda {ConfigFile.delete_project(@project)}.should_not raise_error
      end
    end
  end

  describe 'setting a custom path' do
    before(:each) do
      @original_path = ENV['CODEFUMES_CONFIG_FILE']
      ENV['CODEFUMES_CONFIG_FILE'] = nil
    end

    after(:all) do
      ENV['CODEFUMES_CONFIG_FILE'] = @original_path
    end

    context "via an environment variable" do
      it "updates the value returned from 'path'" do
        new_path = File.expand_path('./tmp/new_config_via_env_var')
        ConfigFile.path.should == File.expand_path('~/.codefumes_config')
        ENV['CODEFUMES_CONFIG_FILE'] = new_path
        ConfigFile.path.should == new_path
      end
    end

    context "via path=" do
      it "updates the value returned from 'path'" do
        new_path = File.expand_path('./tmp/new_config')
        ConfigFile.path.should == File.expand_path('~/.codefumes_config')
        ConfigFile.path = new_path
        ConfigFile.path.should == new_path
      end
    end
  end

end
