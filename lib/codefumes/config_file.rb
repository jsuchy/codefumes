module CodeFumes
  # CodeFumes uses a global (per-user) config file to store relevant
  # information around a user's use of the service.  Doing so addresses
  # the following goals:
  # * A defined location for all tools to utilize which contains URI's
  #   and and keys for all projects a user has set up on
  #   CodeFumes.com[http://codefumes.com], simplifying integration.
  # * Associating (or disassociating) a project to (or from) a CodeFumes
  #   project does not require any modifications to said project's
  #   repository.
  # * Simplified the implementation of 'user-less' projects on the
  #   website.
  #
  # This class wraps up reading and writing this config file so other
  # developers should not have to concern themselves with how to
  # serialize & write the data of a project into the appropriate format,
  # output file, et cetera.
  class ConfigFile
    DEFAULT_FILE_STRUCTURE = {}
    DEFAULT_PATH = File.expand_path('~/.codefumes_config')

    class << self
      # Returns the path to the CodeFumes global (per-user) config file.
      # The default path is '~/.codefumes_config'.
      def path
        @path || ENV['CODEFUMES_CONFIG_FILE'] || DEFAULT_PATH.dup
      end

      # Sets the path which should be used for storing the configuration
      # CodeFumes.com data.
      def path=(custom_path)
        @path = custom_path.nil? ? path : File.expand_path(custom_path)
      end

      # Store the supplied project into the CodeFumes config file.
      def save_project(project)
        update_config_file do |config|
          if config[:projects]
            config[:projects].merge!(project.to_config)
          else
            config[:projects] = project.to_config
          end
        end
      end
      
      # Remove the supplied project from the CodeFumes config file.
      def delete_project(project)
        update_config_file do |config|
          config[:projects] && config[:projects].delete(project.public_key.to_sym)
        end
      end

      def save_credentials(username,api_key)
        update_config_file do |config|
          config.merge!(:credentials => {:username => username, :api_key => api_key})
        end
      end


      # Returns a Hash representation of the CodeFumes config file
      def serialized
        empty? ? DEFAULT_FILE_STRUCTURE.dup : loaded
      end

      # Returns a Hash representation of a specific project contained in
      # the CodeFumes config file.
      def options_for_project(public_key)
        config = serialized
        public_key && config[:projects] && config[:projects][public_key.to_sym] || {}
      end

      private
        def write(serializable_object)
          File.open(path, 'w') do |f|
            f.puts YAML::dump(serializable_object)
          end
        end

        def exists?
          File.exists?(path)
        end

        def empty?
          !(exists? && loaded)
        end

        def loaded
          YAML::load_file(path)
        end
        
        def update_config_file(&block)
          config = serialized
          yield config
          write(config)
        end
    end
  end
end
