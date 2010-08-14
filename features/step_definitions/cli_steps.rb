# still a super-hack...but at least it's not duplicated, right?
# ...
# ...right?
def output_message_qty(action)
  combined_output.scan(/#{action}\.\.\.'.*': Success/).count
end

def clone_fixture_repo_into(dir_name)
  Given "I run \"git clone git@github.com:cosyn/git_fixture_repository.git #{dir_name}\""
end

# TODO: Get a better way of testing this...output is horrible
Then /^the output should contain (\d+) successful claim message[s]?$/ do |count|
  output_message_qty("Claiming").should == count.to_i
end

# TODO: Get a better way of testing this...output is horrible
Then /^the output should contain (\d+) successful release message[s]?$/ do |count|
  output_message_qty("Releasing").should == count.to_i
end

# TODO: Get a better way of testing this...output is horrible
Then /^the output should contain (\d+) successful delete message[s]?$/ do |count|
  output_message_qty("Deleting").should == count.to_i
end

Then /^the output should contain instructions about storing your API key$/ do
    Then "the output should contain \"fumes setup\""
end

Given /^I have cloned and synchronized (\d+) project[s]?$/ do |qty|
  (1..qty.to_i).each do |index|
    dir_name = "project_#{index}"
    clone_fixture_repo_into(dir_name)
    And "I synchronize project #{index}"
  end
end

Given /^I have cloned (\d+) project[s]?$/ do |qty|
  (1..qty.to_i).each do |index|
    dir_name = "project_#{index}"
    clone_fixture_repo_into(dir_name)
  end
end

When /^I (?:have )?synchronize[d]? project (\d+)$/ do |index|
  When "I cd to \"project_#{index}/\""
  And "I run \"#{@bin_path}/fumes sync\""
  And "I cd to \"../\""
end

# convenience step...assumes only one project
When /^I (?:have)?synchronize[d]? the project$/ do
  When "I synchronize project 1"
end

Given /^I (?:have )?claim(?:ed)? the (\d+)st project$/ do |index|
  dir_name = "project_#{index}"
  And "I cd to \"#{dir_name}/\""
  And "I run \"#{@bin_path}/fumes claim\""
  And "I cd to \"../\""
end

# convenience step...assumes only one project
Given /^I (?:have )?claim(?:ed)? the project$/ do
  Given "I have claimed the 1st project"
end

Given /^I (?:have )?release[d]? the (\d+)(?:st|nd|rd|th) project$/ do |index|
  dir_name = "project_#{index}"
  And "I cd to \"#{dir_name}/\""
  And "I run \"#{@bin_path}/fumes release\""
  And "I cd to \"../\""
end

# TODO: Refactor w/ other actions
Given /^I (?:have )?delete[d]? the (\d+)(?:st|nd|rd|th) project$/ do |index|
  dir_name = "project_#{index}"
  And "I cd to \"#{dir_name}/\""
  And "I run \"#{@bin_path}/fumes delete\""
  And "I cd to \"../\""
end

# convenience step...assumes only one project
Given /^I (?:have )?delete(?:ed)? the project$/ do
  Given "I have deleted the 1st project"
end


# convenience step...assumes only one project
Given /^I (?:have )?release[d]? the project$/ do
  Given "I have released the 1st project"
end
