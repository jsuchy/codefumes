Then /^the output should contain (\d+) successful claim[s]?$/ do |count|
  # super hack...super tired
  combined_output.scan(/Success/).should == Array.new(count.to_i, "Success")
end
