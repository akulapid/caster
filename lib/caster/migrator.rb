require 'caster/migration'
require 'caster/metadata/metadata_document'
require 'couchrest'

module Caster

  class Migrator

    def initialize metadata
      @dbs = {}
      @metadata = metadata
      Caster.log.info "using #{metadata.desc} for storing metadata documents."
    end
    
    def migrate_in_dir path, migrate_database = nil, max_version = nil

      all_migrations = {}

      path = path.sub /(\/)+$/, ''
      Dir["#{path}/*.cast"].map do |file|
        migration_version, database = File.basename(file, '.cast').split '.'

        @dbs[database] = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database}" if @dbs[database] == nil

        all_migrations[database] = [] if all_migrations[database] == nil

        all_migrations[database] << {
            :current_version => @metadata.get_db_version(database),
            :version => migration_version,
            :filepath => file
        }
      end

      all_migrations.each_pair do |database, migrations|

        db_filtered = (migrate_database == nil)? migrations.map : migrations.map do |migration|
          migration if migrate_database == database
        end.compact

        min_version_filtered = db_filtered.map do |migration|
          migration if migration[:current_version] == nil or migration[:version] > migration[:current_version]
        end.compact

        max_version_filtered = min_version_filtered.map do |migration|
          migration if max_version == nil or migration[:version] <= max_version
        end.compact

        filtered_and_sorted_files = max_version_filtered.map do |migration|
          migration[:filepath]
        end.sort

        filtered_and_sorted_files.each do |file|
          migrate_file file
        end
      end

    end

    def migrate_file path
      filename = File.basename path, '.cast'
      version, database = filename.split '.'
      current_version = @metadata.get_db_version database

      if current_version != nil and version <= current_version
        raise 'Cannot migrate down!'
      else
        migrate_script database, File.open(path).read
        @metadata.save_db_version database, version
      end

    end
  end
end
