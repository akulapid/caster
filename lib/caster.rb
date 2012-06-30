require 'yaml'
require 'caster/migration'
require 'caster/migrator'

module Caster

  @config = {
    :host => '127.0.0.1',
    :port => '5984'
  }

  @valid_config_keys = @config.keys

  def self.configure opts = {}
    opts.each do |k, v|
      @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym
    end
  end

  def self.configure_with path_to_yaml_file
    begin
      config = YAML.load_file path_to_yaml_file
    rescue Errno::ENOENT
      log :warning, "YAML configuration file couldn't be found.. using defaults."
      return
    rescue Psych::SyntaxError
      log :warning, "YAML configuration file contains invalid syntax.. using defaults."
      return
    end
    configure(config)
  end

  def self.config
    @config
  end
end