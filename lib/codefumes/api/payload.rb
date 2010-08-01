module CodeFumes
  module API
    # Payloads are intended to simplify sending up large amounts of
    # content at one time.  For example, when sending up the entire
    # history of a repository, making a POST request for each commit would
    # require a very large number of requests.  Using a Payload object
    # allows larger amounts of content to be saved at one time,
    # significantly reducing the number of requests made.
    class Payload
      PAYLOAD_CHARACTER_LIMIT = 4000 #:nodoc:

      attr_reader :project, :created_at

      # +:commit_data+ should be a list of commits and associated data.
      # An example would be:
      #
      #   [{:identifier => "commit_identifer", :files_affected => 3,
      #     :custom_attributes => {:any_metric_you_want => "value"}}]
      def initialize(project, commit_data)
        @project = project
        @content = {:commits => commit_data}
      end

      # Saves instance to CodeFumes.com. After a successful save, the
      # +created_at+ attribute will be populated with the timestamp the
      # Payload was created.
      #
      # Returns +true+ if the Payload does not contain any content to be
      # saved or the request was successful.
      #
      # Returns +false+ if the request failed.
      def save
        return true if empty_payload?
        response = API.post("/projects/#{@project.public_key}/payloads", :query => {:payload => @content}, :basic_auth => {:username => @project.public_key, :password => @project.private_key})

        case response.code
          when 201
            @created_at = response['payload']['created_at']
            true
          else
            false
        end
      end

      # +save+ requests are made with a standard POST request (not a
      # multi-part POST), so the request size is limited by the
      # application server.  The current configuration on CodeFumes.com
      # limits requests to approximately 8,000 bytes (a little over).  In
      # order to simplify dealing with these constraints, without
      # requiring a multi-part POST request, +prepare+ can be used to
      # "chunk" up the data into Payloads which do not exceed this limit.
      #
      # Returns collection of payload objects which fall into the
      # constraints of a individual payload (ie: length of raw request,
      # et cetera).
      #--
      # TODO: Clean up how the size of the request is constrained, this
      # is pretty hackish right now (basically guesses how many
      # characters would be added when HTTParty wraps the content in XML.)
      def self.prepare(project, commit_data = {})
        return [] if commit_data.nil? || commit_data.empty?
        raw_payload = commit_data.dup

        content = raw_payload[:commits]
        initial_chunks = {:on_deck => [], :prepared => []}

        # TODO: Clean this up
        chunked = content.inject(initial_chunks) do |chunks, new_commit|
          if chunks[:on_deck].to_s.length + new_commit.to_s.length >= PAYLOAD_CHARACTER_LIMIT
            chunks[:prepared] << chunks[:on_deck]
            chunks[:on_deck] = [new_commit]
          elsif new_commit == content.last
            chunks[:on_deck] << new_commit
            chunks[:prepared] << chunks[:on_deck]
            chunks[:on_deck] = []
          else
            chunks[:on_deck] << new_commit
          end
          chunks
        end

        chunked[:prepared].map do |raw_content|
          Payload.new(project, raw_content)
        end
      end

      private
        def empty_payload?
          @content.nil? || @content.empty? || @content[:commits].nil? || @content[:commits].blank?
        end
    end
  end
end
