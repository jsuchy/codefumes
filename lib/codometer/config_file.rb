module Codometer
  module ConfigFile
    extend self
    DEFAULT_FILE_STRUCTURE = {}.dup
    DEFAULT_PATH = File.expand_path('~/.codometer_config')

    def self.path
      DEFAULT_PATH
    end

    def self.save_project(project)
      config = serialized
      if config[:projects]
        config[:projects].merge!(project.to_config)
      else
        config[:projects] = project.to_config
      end
      write(config)
    end

    def self.delete_project(project)
      config = serialized
      config[:projects].delete(project.public_key.to_sym)
      write(config)
    end

    def self.serialized
      empty? ? DEFAULT_FILE_STRUCTURE : loaded
    end

    class << self
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
end
