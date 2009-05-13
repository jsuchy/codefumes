module Codometer
  class ConfigFile
    DEFAULT_PATH = File.expand_path('~/.codometer_config')

    def self.path
      DEFAULT_PATH
    end
  end
end
