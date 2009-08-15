module CodeFumes
  class Payload
    PAYLOAD_CHARACTER_LIMIT = 4000
    include HTTParty
    base_uri 'http://www.codefumes.com/api/v1/xml'
    #base_uri 'http://localhost:3000/api/v1/xml'
    format :xml
    attr_reader :project_public_key, :created_at

    def initialize(options = {})
      @project_public_key = options[:public_key]
      @content = options[:content]
    end

    def save
      return true if empty_payload?
      response = self.class.post("/projects/#{@project_public_key}/payloads", :query => {:payload => @content})

      case response.code
      when 201
        @created_at = response['payload']['created_at']
        true
      else
        false
      end
    end

    # Returns collection of payload objects which fall into the constraints of
    # a individual payload (ie: length of raw request, etc)
    def self.prepare(data = {})
      return [] if data.nil? || data.empty?
      raw_payload = data.dup

      public_key = raw_payload.delete(:public_key)
      raise ArgumentError, "No public key provided" if public_key.nil?

      if raw_payload[:content].nil? || raw_payload[:content][:commits].nil?
        raise ArgumentError, "No commits key provided"
      end

      content = raw_payload[:content][:commits]
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
        Payload.new(:public_key => public_key, :content => {:commits => raw_content})
      end
    end

    private
      def empty_payload?
        @content.empty? || @content[:commits].nil? || @content[:commits].blank?
      end
  end
end
