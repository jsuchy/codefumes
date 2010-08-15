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
        STDERR.puts "Sorry, you need to install launchy: `gem install launchy`"
      end
    end

    # lifted from the Github gem
    def open_in_browser(url, &block)
      has_launchy? {Launchy::Browser.new.visit url}
    end
  end
end
