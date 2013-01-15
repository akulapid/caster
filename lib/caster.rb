require 'yaml'
require 'logger'
require 'caster/migration'

include Caster

module Caster

  @config = {
    'host' => '127.0.0.1',
    'port' => '5984',
    'metadata' => {
        'database' => nil,
        'design_doc_id' => 'caster_meta',
        'key' => {
            'type' => 'caster_metadoc'
        },
    },
    'batch_size' => 2000,
    'log_level' => 'info',
  }

  @valid_config_keys = @config.keys

  @logger = Logger.new STDOUT
  @logger.level = Logger.const_get((@config.has_key?('log_level'))? @config['log_level'].upcase : 'INFO')

  def self.config
    @config
  end

  def self.log
    @logger
  end

  def self.configure opts = {}
    opts.each do |k, v|
      @config[k] = v if @valid_config_keys.include? k
    end
  end

  def self.configure_with path_to_yaml_file
    begin
      configure(YAML.load_file path_to_yaml_file)
    rescue Errno::ENOENT
      Caster.log.warn { "YAML configuration file couldn't be found.. using defaults" }
    rescue Psych::SyntaxError
      Caster.log.warn { "YAML configuration file contains invalid syntax.. using defaults" }
    end
    Caster.log.info { "using configuration: #{@config.inspect}" }
  end

  self.configure_with 'caster.yml'
end
