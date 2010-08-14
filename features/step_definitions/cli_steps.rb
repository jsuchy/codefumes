# still a super-hack...but at least it's not duplicated, right?
# ...
# ...right?
def output_message_qty(action)
  combined_output.scan(/#{action}\.\.\.'.*': Success/).count
end

Then /^the output should contain (\d+) successful claim message[s]?$/ do |count|
  output_message_qty("Claiming").should == count.to_i
end

Then /^the output should contain (\d+) successful release message[s]?$/ do |count|
  output_message_qty("Releasing").should == count.to_i
end

Then /^the output should contain instructions about storing your API key$/ do
    Then "the output should contain \"fumes setup\""
end
