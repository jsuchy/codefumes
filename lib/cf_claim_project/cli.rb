require 'optparse'
require 'codefumes/config_file'
include CodeFumes

module CfClaimProject
  class CLI
    @attempt_to_claim_all = false
    @private_project = false

    def self.execute(stdout, arguments=[])
      @stdout = stdout
      parse_cli_arguments!(arguments)
      retrieve_users_credentials_or_exit


      @public_keys.each do |public_key|
        project = Project.find(public_key)

        if project.nil?
          @stdout.puts "Claiming...'#{public_key}': Not found"
          next
        end

        @stdout.print "Claiming...'#{public_key}': "
        @stdout.puts Claim.create(project, @users_api_key, visibility) ? 'Success!' : 'Denied.'
      end

      @stdout.puts ""
      @stdout.puts "Done!"
    end

    private
      def self.parse_cli_arguments!(arguments)
        OptionParser.new do |opts|
          opts.banner = <<-BANNER.gsub(/^          /,'')
            Used to 'claim' a project on CodeFumes.com. The claim request has a
            "visibility" attribute as well, which defaults to "public", but can
            be set to "private" using the -p/--private flag.

            Usage: #{File.basename($0)} [options]

            Options are:
          BANNER
          opts.separator ""
          opts.on("-a", "--all", String,
                  "Attempt to claim all projects in your CodeFumes config file."
                  ) {@attempt_to_claim_all = true}
          opts.on("-p", "--private", String,
                  "Claims the project(s) as a 'private' project."
                  ) {@private_project = true}
          opts.on("-h", "--help",
                  "Show this help message.") { @stdout.puts opts; exit(1) }
          opts.parse!(arguments)
        end

        @public_keys = claim_all_projects_flag_set? ? ConfigFile.public_keys : arguments.compact
        if @public_keys.empty?
          print_missing_arguments_message
          exit
        end

      end

      def self.claim_all_projects_flag_set?
        @attempt_to_claim_all == true
      end

      def self.visibility
        @private_project == true ? :private : :public
      end

      def self.print_missing_arguments_message
        @stdout.puts "You must specify either a public key of a project, or -a/--all to"
        @stdout.puts "claim all projects in your CodeFumes config file"
        @stdout.puts ""
        @stdout.puts "Exiting."
      end

      def self.retrieve_users_credentials_or_exit
        @users_api_key = ConfigFile.credentials[:api_key]
        return @users_api_key unless @users_api_key.nil?
        @stdout.puts "No API key saved in your CodeFumes config file!"
        @stdout.puts ""
        @stdout.puts "Grab your API key from CodeFumes.com and run 'store_codefumes_credentials [api_key]."
        @stdout.puts "Then try again."
        @stdout.puts ""
        @stdout.puts "Exiting."
        exit
      end
  end
end
