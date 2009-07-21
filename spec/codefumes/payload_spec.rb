require File.dirname(__FILE__) + '/../spec_helper.rb'

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
        FakeWeb.register_uri( :post, "http://www.codefumes.com:80/api/v1/xml/projects/apk/payloads?payload[commits]=data_to_send_up",
                             :status => ["201", "Created"],
                             :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<payload>\n <created_at>Creation Date</created_at>\n  </payload>\n")
      end

      [:created_at].each do |method_name|
        it "sets the '#{method_name.to_s}'" do
          payload = Payload.new(:public_key => @project.public_key, :scm_payload => {:commits => "data_to_send_up"})
          payload.send(method_name).should == nil
          payload.save.should == true
          payload.send(method_name).should_not == nil
        end
      end

    end

    context "when the payload does not have any content" do
      before(:each) do
        @payload = Payload.new(:public_key => @project.public_key, :scm_payload => {:commits => ""})
      end

      it "returns true without attempting to save to the site" do
        @payload.save.should == true
      end

      it "does not set the value of created_at" do
        @payload.save
        @payload.created_at.should == nil
      end
    end

    context "with invalid parameters" do
      before(:each) do
        FakeWeb.register_uri( :post, "http://www.codefumes.com:80/api/v1/xml/projects/apk/payloads?payload[commits]=invalid_data",
                              :status => ["422", "Unprocessable Entity"])
      end

      [:created_at].each do |method_name|
        it "does not set a value for '#{method_name.to_s}'" do
          payload = Payload.new(:public_key => @project.public_key, :scm_payload => {:commits => "invalid_data"})
          payload.save.should == false
          payload.send(method_name).should == nil
        end
      end
    end
  end

  describe "calling the class method" do
    describe "'prepare'" do
      context "when supplying nil content" do
        it "returns an empty array" do
          Payload.prepare(nil).should == []
        end
      end

      context "when supplying an empty Hash" do
        it "returns an empty array" do
          Payload.prepare({}).should == []
        end
      end

      context "when supplying hash does not contain a :public_key key" do
        it "raises an ArgumentError exception" do
          lambda {Payload.prepare({:commits => []})}.should raise_error(ArgumentError)
        end
      end

      context "when supplying hash does not contain a :commits key" do
        it "raises an ArgumentError exception" do
          lambda {Payload.prepare({:public_key => "pub_key1"})}.should raise_error(ArgumentError)
        end
      end

      context "when supplying a hash with less than 5,000 characters" do
        before(:each) do
          single_commit_ex =  {:identifier => "92dd08477f0ca144ee0f12ba083760dd810760a2_000"}
          commit_count = 5000 / single_commit_ex.to_s.length
          commits = commit_count.times.map do |index|
            {:identifier => "92dd08477f0ca144ee0f12ba083760dd810760a2_#{index}"}
          end
          @prepared = Payload.prepare({:public_key => 'fjsk', :scm_payload => {:commits => commits}})
        end

        it "returns an Array with a single payload element" do
          @prepared.should be_instance_of(Array)
          @prepared.size.should == 1
          @prepared.first.should be_instance_of(Payload)
        end
      end

      context "when supplying a hash with approximately 15,000 characters" do
        before(:each) do
          single_commit_ex =  {:identifier => "92dd08477f0ca144ee0f12ba083760dd810760a2_000"}
          commit_count = 15000 / single_commit_ex.to_s.length + 1
          commits = commit_count.times.map do |index|
            {:identifier => "92dd08477f0ca144ee0f12ba083760dd810760a2_#{index}"}
          end
          raw_payload = {:public_key => 'fjsk', :scm_payload => {:commits => commits}}
          @prepared = Payload.prepare(raw_payload)
        end

        it "returns an Array with a three payload elements" do
          @prepared.should be_instance_of(Array)
          @prepared.size.should == 3
          all_are_payloads = @prepared.all? {|chunk| chunk.instance_of?(Payload)}
          all_are_payloads.should == true
        end

        it "the first payload contains approximately 10,000 characters"
        it "the second payload contains approximately 5,000 characters"
      end
    end
  end
end