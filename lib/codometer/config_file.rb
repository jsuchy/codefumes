module Codometer
  class ConfigFile
    DEFAULT_PATH = File.expand_path('~/.codometer_config')
    DEFAULT_SKELETON_STRUCTURE = {}

    def self.path
      DEFAULT_PATH
    end

    def self.save_project(project)
      write do
        config = serialized
        if config[:projects]
          config[:projects].merge!(project.to_config)
        else
          config[:projects] = project.to_config
        end
        config
      end
    end

    def self.serialized
      empty? ? DEFAULT_SKELETON_STRUCTURE : loaded
    end

    private
      def self.write(filename = DEFAULT_PATH, &block)
        File.open(filename, 'w') do |f|
          f.puts YAML::dump(yield) if block_given?
        end
      end

      def self.exists?
        File.exist?(DEFAULT_PATH)
      end

      def self.empty?
        !(exists? && loaded.nil?)
      end

      def self.loaded
        YAML::load_file(path)
      end
  end
end
