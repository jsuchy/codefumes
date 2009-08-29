module CodeFumes
  # Similar to a revision control system, a Commit encompasses a set of
  # changes to a codebase, who made them, when said changes were applied
  # to the previous revision of codebase, et cetera.
  #
  # A Commit has a concept of 'standard attributes' which will always be
  # present in a response from CodeFumes.com[http://codefumes.com], such
  # as the +identifier+, +author+, and +commit_message+ (see the list of
  # attributes for a comprehensive listing).  In addition to this, users
  # are able to associate 'custom attributes' to a Commit, allowing
  # users to link any number of attributes with a commit identifier and
  # easily retrieve them later.
  #
  # One thing to note about Commit objects is that they are read-only.
  # To associate metrics with a Commit object, a Payload object should
  # be created and saved.  Refer to the Payload documentation for more
  # information.
  class Commit < CodeFumes::API
    attr_reader :identifier, :author_name, :author_email, :committer_name,
                :committer_email, :short_message, :message,:committed_at,
                :authored_at, :uploaded_at, :api_uri, :parent_identifiers,
                :line_additions, :line_deletions, :line_total,
                :affected_file_count, :custom_attributes

    # Instantiates a new Commit object
    #
    # Accepts a Hash of options, including:
    # * identifier
    # * author_email
    # * author_name
    # * committer_email
    # * committer_name
    # * short_message
    # * message
    # * committed_at
    # * authored_at
    # * uploaded_at
    # * api_uri
    # * parent_identifiers
    # * line_additions
    # * line_deletions
    # * line_total
    # * affected_file_count
    # * custom_attributes
    #
    # +custom_attributes+ should be a Hash of attribute_name/value
    # pairs associated with the commit.  All other attributes are
    # expected to be String values, other than +committed_at+ and
    # +authored_at+, which are expected to be DateTime objects.
    # Technically speaking, you could pass anything you wanted into
    # the fields, but when using with the CodeFumes API, the attribute
    # values will be of the type String, DateTime, or Hash.
    def initialize(options)
      @identifier          = options["identifier"]
      @author_email        = options["author_email"]
      @author_name         = options["author_name"]
      @committer_email     = options["committer_email"]
      @committer_name      = options["committer_name"]
      @short_message       = options["short_message"]
      @message             = options["message"]
      @committed_at        = options["committed_at"]
      @authored_at         = options["authored_at"]
      @uploaded_at         = options["uploaded_at"]
      @api_uri             = options["api_uri"]
      @parent_identifiers  = options["parent_identifiers"]
      @line_additions      = options["line_additions"]
      @line_deletions      = options["line_deletions"]
      @line_total          = options["line_total"]
      @affected_file_count = options["affected_file_count"]
      @custom_attributes   = options["custom_attributes"] || {}
      convert_custom_attributes_keys_to_symbols
    end

    # Returns the name of the author and the email associated
    # with the commit in a string formatted as:
    #   "Name [email_address]"
    #   (ie: "John Doe [jdoe@example.com]")
    def author
      "#{author_name} [#{author_email}]"
    end

    # Returns the name of the committer and the email associated
    # with the commit in a string formatted as:
    #   "Name [email_address]"
    #   (ie: "John Doe [jdoe@example.com]")
    def committer
      "#{committer_name} [#{committer_email}]"
    end

    # Returns the Commit object associated with the supplied identifier.
    # Returns nil if the identifier is not found.
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

    # Returns a collection of commits associated with the specified
    # Project public key.
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

    # Returns the most recent commit associated with the specified
    # Project public key.
    def self.latest(project_public_key)
      response = get("/projects/#{project_public_key}/commits/latest")
      case response.code
      when 200
        new(response["commit"])
      else
        nil
      end
    end

    # Returns the commit identifier of the most recent commit of with
    # the specified Project public key.
    def self.latest_identifier(project_public_key)
      latest_commit = latest(project_public_key)
      latest_commit.nil? ? nil : latest_commit.identifier
    end

    private
      def convert_custom_attributes_keys_to_symbols
        @custom_attributes = @custom_attributes.inject({}) do |results, key_and_value|
          results.merge! key_and_value.first.to_sym => key_and_value.last
        end
      end
  end
end
