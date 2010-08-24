begin
  require 'codefumes'
rescue LoadError
  abort "Install 'codefumes' gem to use the CodeFumes notifier"
end

module CodeFumes
  class IntegrityNotifier
    class CodeFumes < ::Integrity::Notifier::Base
      attr_reader :private_key, :public_key

      def self.to_haml
        @haml ||= File.read(File.dirname(__FILE__) + "/codefumes.haml")
      end

      def initialize(build, config={})
        @public_key  = config["public_key"]
        @private_key = config["private_key"]
        @build_name  = config["build_name"]
        @repo_path   = Integrity::Repository.new(
          build.id, build.project.uri, build.project.branch, build.commit.identifier
        ).directory
        super(build, config)
      end

      def deliver!
        Integrity.log "Updating build '#{@build_name}' for '#{@public_key}' (state: #{build_state})"
        qb_options = {:public_key  => @public_key,
                      :private_key => @private_key,
                      :ended_at    => @build.completed_at,
                      :repository_path => @repo_path}

        ::CodeFumes::QuickBuild.finish(@build_name, build_state, qb_options)
      end

      def deliver_started_notification!
        Integrity.log "Adding build '#{@build_name}' for '#{@public_key}' (state: #{build_state})"
        qb_options = {:public_key  => @public_key,
                      :private_key => @private_key,
                      :started_at  => @build.started_at,
                      :repository_path => @repo_path}

        ::CodeFumes::QuickBuild.start(@build_name, qb_options)
      end

      private
        def build_state
          case @build.status
          when :success  then :successful
          when :failed   then :failed
          when :building then :running
          end
        end
    end
  end
end

module Integrity
  class Notifier
    register CodeFumes::IntegrityNotifier::CodeFumes
  end
end
