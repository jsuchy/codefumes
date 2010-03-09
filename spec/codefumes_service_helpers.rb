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
      @build_name = "IE7"
      @commit_identifier = "COMMIT_IDENTIFIER"
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
    def register_public_create_uri(status_code = ["200", "Ok"], body_content = "")
      register_create_uri(status_code, body_content, :public)
    end

    def register_private_create_uri(status_code = ["200", "Ok"], body_content = "")
      register_create_uri(status_code, body_content, :private)
    end

    def register_destroy_uri(status_code = ["200", "Ok"], body_content = "")
      request_uri = "#{@authd_project_api_uri}/claim?api_key=#{@api_key}"
      FakeWeb.register_uri(:delete, request_uri, :status => status_code, :body =>  body_content)
    end

    private
      def register_create_uri(status_code, body_content, visibility)
        request_uri = "#{@authd_project_api_uri}/claim?api_key=#{@api_key}&visibility=#{visibility.to_s}"
        FakeWeb.register_uri(:put, request_uri, :status => status_code, :body =>  body_content)
      end
  end

  module Build
    def setup_build_fixtures
      @started_at = "2009-09-26 21:18:11 UTC"
      @esc_started_at = "2009-09-26%2021%3A18%3A11%20UTC"
      @state = "running"
      @build_identifier = "BUILD_IDENTIFIER"
    end

    def register_create_uri(status_code = ["201", "Created"], body_content = fixtures[:build])
      FakeWeb.register_uri(:post, "#{@authd_project_api_uri}/commits/#{@commit_identifier}/builds?build[state]=#{@state}&build[started_at]=#{@esc_started_at}&build[ended_at]=&build[name]=#{@build_name}",
                           :status => status_code, :body => body_content)
    end

    def register_update_uri(status_code = ["200", "Ok"], body_content = fixtures[:build])
      FakeWeb.register_uri(:put, "#{@authd_project_api_uri}/commits/#{@commit_identifier}/builds/#{@build_identifier}?build[state]=#{@state}&build[started_at]=#{@esc_started_at}&build[ended_at]=&build[name]=#{@build_name}",
                           :status => status_code, :body => body_content)
    end

    def register_show_uri(status_code = ["200", "Ok"], body_content = fixtures[:build])
      FakeWeb.register_uri(:get, "#{@anon_project_api_uri}/commits/#{@commit_identifier}/builds/#{@build_identifier}",
                           :status => status_code, :body => body_content)
    end

    def register_delete_uri(status_code = ["200", "Ok"], body_content = fixtures[:project])
      FakeWeb.register_uri(:delete, "#{@authd_project_api_uri}/commits/#{@commit_identifier}/builds/#{@build_identifier}",
                           :status => status_code,
                           :body =>  body_content)
    end
  end
end
