require 'yaml'
require 'logger'
require 'caster/migration'

include Caster

module Caster

  @config = {
    :host => '127.0.0.1',
    :port => '5984',
    :metadata => {
        :database => nil,
        :id_prefix => 'caster',
        :type => 'caster_metadoc'
    },
    :batch_size => 2000,
  }

  @valid_config_keys = @config.keys

  @logger = Logger.new STDOUT

  def self.configure opts = {}
    opts.each do |k, v|
      @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym
    end
  end

  def self.configure_with path_to_yaml_file
    begin
      config = YAML.load_file path_to_yaml_file
    rescue Errno::ENOENT
      puts "YAML configuration file couldn't be found.. using defaults."
      return
    rescue Psych::SyntaxError
      puts "YAML configuration file contains invalid syntax.. using defaults."
      return
    end
    configure(config)
  end

  self.configure_with 'caster.yml'

  def self.config
    @config
  end

  def self.log
    @logger
  end
end
