require File.dirname(__FILE__) + '/../spec_helper.rb'

def register_create_uri
  FakeWeb.register_uri( :post, "http://www.codometer.net:80/api/v1/xml/projects/apk/payloads?payload=data_to_send_up",
                        :status => ["201", "Created"],
                        :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<payload>\n <created_at>Creation Date</created_at>\n  </payload>\n")
end


describe "Payload" do
  after(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  describe "save" do
    before(:each) do
      @project = Project.new(:public_key => "apk")
    end

    context "with valid parameters" do
      before(:each) do
        register_create_uri
      end

      [:created_at].each do |method_name|
        it "sets the '#{method_name.to_s}'" do
          payload = Payload.new(:public_key => @project.public_key, :scm_payload => "data_to_send_up")
          payload.send(method_name).should == nil
          payload.save.should == true
          payload.send(method_name).should_not == nil
        end
      end
    end

    context "with invalid parameters" do
      before(:each) do
        FakeWeb.register_uri( :post, "http://www.codometer.net:80/api/v1/xml/projects/apk/payloads?payload=invalid_data",
                              :status => ["422", "Unprocessable Entity"])
      end

      [:created_at].each do |method_name|
        it "does not set a value for '#{method_name.to_s}'" do
          payload = Payload.new(:public_key => @project.public_key, :scm_payload => "invalid_data")
          payload.save.should == false
          payload.send(method_name).should == nil
        end
      end
    end
  end
end
