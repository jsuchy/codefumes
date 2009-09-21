module CodeFumesServiceStubs
  def single_commit(options = {})
    commit_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    commit_xml += <<-END_OF_COMMIT
    <commit>
      <identifier>f3badd5624dfbcf5176f0471261731e1b92ce957</identifier>
      <author_name>John Doe</author_name>
      <author_email>jdoe@example.com</author_email>
      <committer_name>John Doe</committer_name>
      <committer_email>jdoe@example.com</committer_email>
      <short_message>Made command-line option for 'name' actually work</short_message>
      <message>
        Made command-line option for 'name' actually work
        - Commentd out hard-coded 'require' line used for testing
      </message>
      <parent_identifiers>9ddj48423jdsjds5176f0471261731e1b92ce957,3ewdjok23jdsjds5176f0471261731e1b92ce957,284djsksjfjsjds5176f0471261731e1b92ce957</parent_identifiers>
      <committed_at>Wed May 20 09:09:06 -0500 2009</committed_at>
      <authored_at>Wed May 20 09:09:06 -0500 2009</authored_at>
      <uploaded_at>2009-06-04 02:43:20 UTC</uploaded_at>
      <api_uri>http://localhost:3000/api/v1/commits/f3badd5624dfbcf5176f0471261731e1b92ce957.xml</api_uri>
      <line_additions>20</line_additions>
      <line_deletions>10</line_deletions>
      <line_total>30</line_total>
      <affected_file_count>2</affected_file_count>
    END_OF_COMMIT

    if options[:include_custom_attributes]
      commit_xml <<
      <<-END_OF_COMMIT
        <custom_attributes>
          <coverage>83</coverage>
          <random_attribute>1</random_attribute>
        </custom_attributes>
      END_OF_COMMIT
    end

    commit_xml << "\n</commit>"
  end

  def register_index_uri
    FakeWeb.register_uri(
      :get, "http://www.codefumes.com:80/api/v1/xml/projects/apk/commits",
      :status => ["200", "Ok"],
      :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<commits>\n#{single_commit}\n#{single_commit}\n#{single_commit}\n</commits>\n")
  end

  def stub_codefumes_uri(api_uri, status, response_string)
    FakeWeb.register_uri(
      :get, "http://www.codefumes.com:80/api/v1/xml/#{api_uri}",
      :status => status,
      :string =>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{response_string}")
  end
end

