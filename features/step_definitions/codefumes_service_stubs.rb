Given /^the attempt to synchronize the project will (fail|succeed)$/ do |fail_succeed|
  mock_harvester = mock("Harvester Mock", :results => {:successful_count => 2, :total_count => 3})
  mock_harvester.stub!(:publish_data! => (fail_succeed == 'succeed'))
  Harvester.stub!(:new).and_return(mock_harvester)
end
