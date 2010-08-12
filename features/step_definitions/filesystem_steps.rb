Given /^I am in the CodeFumes gem's root directory$/ do
  cd("/" + File.expand_path(__FILE__) + "/../")
end

Given /^(in)?valid user credentials have been stored in the CodeFumes config file$/ do |invalid_text|
  # Fragile, as this user is not set up to be re-added after wiping test db on CodeFumes.com
  # TODO: update deployment for test site to reload this information:
  # login: test-user
  # password: password
  # email: test.user@codefumes.com
  # api_key: eX2Kue_6YoEIWAvV1VCx

  unless ConfigFile.path.match(/#{File.expand_path(@tmp_root)}/)
    raise "###NOTE### ConfigFile path not set to use temp file. Check CODEFUMES_CONFIG_FILE settings!"
  end

  api_key = invalid_text.blank? ? 'eX2Kue_6YoEIWAvV1VCx' : 'invalid-key-here'
  ConfigFile.save_credentials(api_key)
end
