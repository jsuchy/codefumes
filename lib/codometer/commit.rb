module Codometer
  class Commit
    include HTTParty
    base_uri "http://www.codometer.net/api/v1/xml"
    format :xml
    attr_reader :identifier, :author_name, :author_email, :committer_name,
                :committer_email, :short_message, :message,:committed_at,
                :authored_at, :uploaded_at, :api_uri, :parent_identifiers

    def initialize(options)
      @identifier      = options["identifier"]
      @author_email    = options["author_email"]
      @author_name     = options["author_name"]
      @committer_email = options["committer_email"]
      @committer_name  = options["committer_name"]
      @short_message   = options["short_message"]
      @message         = options["message"]
      @committed_at    = options["committed_at"]
      @authored_at     = options["authored_at"]
      @uploaded_at     = options["uploaded_at"]
      @api_uri         = options["api_uri"]
      @parent_identifiers = options["parent_identifiers"]
    end

    def author
      "#{author_name} [#{author_email}]"
    end

    def committer
      "#{committer_name} [#{committer_email}]"
    end

    def self.find(identifier)
      response = get("/commits/#{identifier}")
      case response.code
      when 200
        return nil if response["commit"].empty?
        new(response["commit"])
      else
        nil
      end
    end

    def self.all(project_public_key)
      response = get("/projects/#{project_public_key}/commits")
      case response.code
      when 200
        return [] if response["commits"].empty? || response["commits"]["commit"].nil?
        response["commits"]["commit"].map do |commit_data|
          new(commit_data)
        end
      else
        nil
      end
    end

    def self.latest(project_public_key)
      response = get("/projects/#{project_public_key}/commits/latest")
      case response.code
      when 200
        new(response["commit"])
      else
        nil
      end
    end

    def self.latest_identifier(project_public_key)
      latest_commit = latest(project_public_key)
      latest_commit.nil? ? nil : latest_commit.identifier
    end
  end
end
