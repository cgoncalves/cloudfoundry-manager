require 'yaml'

module Cloudfoundry
  module Manager

    def self.config
      @@config
    end

    def self.load_config(file_path)
      @@config_file = file_path
      @@config = YAML::load_file(file_path)
      @@config
    end

    def self.save_config
      File.open(@@config_file, "w") {|file| file.puts(@@config.to_yaml) }
    end
  end
end
