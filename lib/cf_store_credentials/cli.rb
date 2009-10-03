require 'optparse'

module CfStoreCredentials #:nodoc:
  class CLI #:nodoc:
    def self.execute(stdout, arguments=[])
      @stdout = stdout
      parse_command_line_options!(arguments)
      api_key = arguments.first

      if CodeFumes::ConfigFile.credentials.empty? || @force_overwrite == true
        CodeFumes::ConfigFile.save_credentials(api_key)
        @stdout.puts "Saved credentials to codefumes config file.\n\nExiting."
      else
        if CodeFumes::ConfigFile.credentials == api_key
          @stdout.puts "Credentials already stored in config file!\n"
        else
          @stdout.puts "You have already stored CodeFumes credentials.\n\n"
          @stdout.puts "The current value you have stored is: #{CodeFumes::ConfigFile.credentials[:api_key]}\n\n"
          @stdout.puts "If you would like to replace this value, execute:\n\n"
          @stdout.puts "\t#{File.basename($0)} --force #{api_key}\n\n"
        end
      end
    end

    private
      def self.parse_command_line_options!(arguments)
        @force_overwrite = false

        parser = OptionParser.new do |opts|
          opts.banner = <<-BANNER.gsub(/^          /,'')
            Stores user's API_KEY from CodFumes.com in the CodeFumes global config file.

            Usage: #{File.basename($0)} [options] api_key

            Options are:
          BANNER
          opts.separator ""
          opts.on("-h", "--help",
                  "Show this help message.") { @stdout.puts opts; exit }
          opts.on("-f", "--force",
                  "Force overwrite of existing API key in config file.") { @force_overwrite = true }
          opts.parse!(arguments)

          if arguments.size != 1
            @stdout.puts opts; exit
          end
        end
      end
  end
end
