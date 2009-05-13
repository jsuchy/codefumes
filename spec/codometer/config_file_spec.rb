require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "ConfigFile" do
  context "class method" do
    describe "'path'" do
      it "returns a the full path to a dotfile named '.codometer_config' in the user's home directory" do
        ConfigFile.path.should == File.expand_path('~/.codometer_config')
      end
    end
  end
end
