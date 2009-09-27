module CodeFumesServiceHelpers
  module Shared
    # These are used pratically _everywhere_
    def setup_fixture_base
      @project_name = "Project_Name(tm)"
      @pub_key = 'public_key_value'
      @priv_key = 'private_key_value'
      @project = CodeFumes::Project.new(:public_key => @pub_key, :private_key => @priv_key, :name => @project_name)

      @anonymous_base_uri = "http://codefumes.com/api/v1/xml"
      @authenticated_base_uri = "http://#{@pub_key}:#{@priv_key}@codefumes.com/api/v1/xml"
      @authd_project_api_uri = "#{@authenticated_base_uri}/projects/#{@pub_key}"
      @anon_project_api_uri = "#{@anonymous_base_uri}/projects/#{@pub_key}"
      @updated_name = @project_name + "_updated"
      @commit_data = "commit_data"
      @api_key = "USERS_API_KEY"
    end

    def fixtures
      @fixtures ||= ResponseFixtureSet.new
    end
  end

  module Project
    def register_no_param_create_uri(status_code = ["200", "Ok"], body_content = fixtures[:project])
      FakeWeb.register_uri( :post, "#{@anonymous_base_uri}/projects?project[name]=&project[public_key]=",
                            :status => status_code,
                            :body => body_content)
    end

    def register_create_uri(status_code = ["200", "Ok"], body_content = fixtures[:project])
      FakeWeb.register_uri( :post, "#{@anonymous_base_uri}/projects?project[name]=#{@project_name}&project[public_key]=#{@pub_key}",
                            :status => status_code,
                            :body => body_content)
    end

    def register_update_uri(status_code = ["200", "Ok"], body_content = fixtures[:project])
      FakeWeb.register_uri(:put, "#{@authd_project_api_uri}?project[name]=#{@project_name}_updated",
                           :status => status_code,
                           :body => body_content)
    end

    def register_show_uri(status_code = ["200", "Ok"], body_content = fixtures[:project])
      FakeWeb.register_uri(:get, @anon_project_api_uri,
                           :status => status_code,
                           :body =>  body_content)
    end

    def register_delete_uri(status_code = ["200", "Ok"], body_content = fixtures[:project])
      FakeWeb.register_uri(:delete, @authd_project_api_uri,
                           :status => status_code,
                           :body =>  body_content)
    end
  end

  module Commit
    def register_latest_uri(status_code = ["200", "Ok"], body_content = fixtures[:commit])
      FakeWeb.register_uri(:get, "#{@anon_project_api_uri}/commits/latest",
                           :status => status_code, :body => body_content)
    end

    def register_index_uri(status_code = ["200", "Ok"], body_content = fixtures[:multiple_commits])
      FakeWeb.register_uri( :get, "#{@anon_project_api_uri}/commits",
                            :status => status_code,
                            :body =>  body_content)
    end

    def register_find_uri(status_code = ["200", "Ok"], body_content = fixtures[:commit])
      FakeWeb.register_uri(:get, "#{@anonymous_base_uri}/commits/#{@identifier}",
                           :status => status_code, :body => body_content)
    end
  end

  module Payload
    def register_create_uri(status_code = ["200", "Ok"], body_content = fixtures[:payload])
      FakeWeb.register_uri(:post, "#{@authd_project_api_uri}/payloads?payload[commits]=#{@commit_data}",
                           :status => status_code, :body => body_content)
    end
  end

  module Claim
    def register_create_uri(status_code = ["201", "Created"], body_content = "")
      request_uri = "#{@authd_project_api_uri}/claim?api_key=#{@api_key}"
      FakeWeb.register_uri(:post, request_uri, :status => status_code, :body =>  body_content)
    end
  end
end
