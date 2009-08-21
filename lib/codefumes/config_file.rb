module CodeFumes
  module ConfigFile
    extend self
    DEFAULT_FILE_STRUCTURE = {}
    DEFAULT_PATH = File.expand_path('~/.codefumes_config')

    def path
      @path || ENV['CODEFUMES_CONFIG_FILE'] || DEFAULT_PATH
    end

    def path=(custom_path)
      @path = File.expand_path(custom_path)
    end

    def save_project(project)
      config = serialized
      if config[:projects]
        config[:projects].merge!(project.to_config)
      else
        config[:projects] = project.to_config
      end
      write(config)
    end

    def delete_project(project)
      config = serialized
      config[:projects].delete(project.public_key.to_sym)
      write(config)
    end

    def serialized
      empty? ? DEFAULT_FILE_STRUCTURE : loaded
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
  end
end
