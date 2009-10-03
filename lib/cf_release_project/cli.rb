require 'optparse'
include CodeFumes

module CfReleaseProject
  class CLI
    def self.execute(stdout, arguments=[])
      @stdout = stdout
      @users_api_key = ConfigFile.credentials[:api_key]
      parse_cli_options(arguments)

      @public_keys.each do |public_key|
        project = Project.find(public_key)

        if project.nil?
          @stdout.puts "Claiming...'#{public_key}': Not found"
          next
        end

        @stdout.print "Claiming...'#{public_key}': "
        @stdout.puts Claim.destroy(project, @users_api_key) ? 'Success!' : 'Denied.'
      end

      @stdout.puts ""
      stdout.puts "Done."
    end

    private
      def self.parse_cli_options(arguments)
        parser = OptionParser.new do |opts|
          opts.banner = <<-BANNER.gsub(/^          /,'')
            Removes the claim of ownership on a CodeFumes project, making
            the project visible to the public and possible for other users
            to claim.

            Usage: #{File.basename($0)} [PROJECT_PUBLIC_KEY]

            Options are:
          BANNER
          opts.separator ""
          opts.on("-a", "--all",
                  "Release all projects listed in your CodeFumes config file."
                 ) {@attempt_to_release_all = true}
          opts.on("-l", "--local",
                  "Send requests to localhost. (Testing/Development)") { CodeFumes::API.mode(:local) }
          opts.on("-t", "--test",
                  "Send requests to test.codefumes.com. (Testing/Development)") { CodeFumes::API.mode(:test) }
          opts.on("-h", "--help",
                  "Show this help message."
                 ) {@stdout.puts opts; exit}
          opts.parse!(arguments)

          @public_keys = release_all_projects_flag_set? ? ConfigFile.public_keys : arguments.compact
          if @public_keys.empty?
            print_missing_arguments_message
            exit
          end

          if arguments.empty?
            @stdout.puts "No public key specified"
            @stdout.puts opts; exit
          end
        end
      end

      def self.release_all_projects_flag_set?
        @attempt_to_release_all == true
      end

      def self.print_missing_arguments_message
        @stdout.puts "You must specify either a public key of a project, or -a/--all to"
        @stdout.puts "claim all projects in your CodeFumes config file"
        @stdout.puts ""
        @stdout.puts "Exiting."
      end
  end
end
