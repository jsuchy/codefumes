module Codometer
  class Payload
    PAYLOAD_CHARACTER_LIMIT = 5000
    include HTTParty
    base_uri 'http://www.codometer.net/api/v1/xml'
    format :xml
    attr_reader :project_public_key, :content, :created_at

    def initialize(options = {:content => nil})
      @project_public_key = options[:public_key]
      @scm_payload = options[:scm_payload]
    end

    def save
      return true if empty_payload?
      response = self.class.post("/projects/#{@project_public_key}/payloads", :query => {:payload => payload})

      case response.code
      when 201
        @created_at = response['payload']['created_at']
        true
      else
        false
      end
    end

    # Returns collection of payload objects which fall
    # into the constraints of a individual payload
    # (ie: length of raw request, etc)
    def self.prepare(data = {})
      return [] if data.nil? || data.empty?
      raw_payload = data.dup

      public_key = raw_payload.delete(:public_key)
      raise ArgumentError, "No public key provided" if public_key.nil?

      if raw_payload[:scm_payload].nil? || raw_payload[:scm_payload][:commits].nil?
        raise ArgumentError, "No commits key provided"
      end

      scm_payload = raw_payload[:scm_payload][:commits]
      initial_chunks = {:on_deck => [], :prepared => []}

      # TODO: Clean this up
      chunked = scm_payload.inject(initial_chunks) do |chunks, new_commit|
        if chunks[:on_deck].to_s.length + new_commit.to_s.length >= PAYLOAD_CHARACTER_LIMIT
          chunks[:prepared] << chunks[:on_deck]
          chunks[:on_deck] = [new_commit]
        elsif new_commit == scm_payload.last
          chunks[:on_deck] << new_commit
          chunks[:prepared] << chunks[:on_deck]
          chunks[:on_deck] = []
        else
          chunks[:on_deck] << new_commit
        end
        chunks
      end

      chunked[:prepared].map do |raw_scm_payload|
        Payload.new(:public_key => public_key, :scm_payload => {:commits => raw_scm_payload})
      end
    end

    private
      def payload
        @scm_payload
      end

      def empty_payload?
        payload.empty? || payload[:commits].nil? || payload[:commits].blank?
      end
  end
end
