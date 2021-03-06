module CodeFumes
  # Module with convenience methods used in 'fumes' command line executable
  module CLIHelpers #nodoc
    def public_keys_specified(options)
      return ConfigFile.public_keys if options[:all]
      [options[:public_key] || SourceControl.new('./').public_key]
    end

    def print_api_mode_notification
      puts "NOTE: Sending all requests & data to non-production server! (#{API.base_uri})"
    end

    def issuing_build_command?(command)
      command && command.name.to_sym == :build
    end

    def build_name_specified?(args)
      !args.first.nil?
    end

    def actionable_flag_specified?(options)
      actionable_flags = [:finished, :status, :start, :exec]
      !actionable_flags.select {|flag| options[flag]}.empty?
    end

    def updating_build_state?(options)
      !!(options[:start] || options[:finished])
    end

    def checking_build_status?(options)
      !!(options[:status])
    end

    def scoped_to_all_builds?(options)
      options[:all]
    end

    def issue_project_commands(message, public_keys, &block)
      public_keys.each do |public_key|
        print "#{message}...'#{public_key}': "
        project = Project.find(public_key.to_s)
        yield(project)
      end

      puts ""
      puts "Done!"
    end

    def wrap_with_standard_feedback(project, &block)
      if project.nil?
        puts "Project Not Found."
      elsif yield != true
        puts "Denied."
      else
        puts "Success!"
      end
    end

    def command_doesnt_use_api?(command)
      [:'api-key'].include?(command.name)
    end

    # lifted from the Github gem
    def has_launchy?(&block)
      begin
        gem 'launchy'
        require 'launchy'
        block.call
      rescue Gem::LoadError
        raise Errors::MissingLaunchyGem, "'launchy' gem required, but missing"
      end
    end

    # lifted from the Github gem
    def open_in_browser(url, &block)
      has_launchy? {Launchy::Browser.new.visit url}
    end

    def multiple_build_states?(options)
      options[:start] && options[:finished]
    end
  end
end
