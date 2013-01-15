require 'caster/migration'
require 'caster/metadata/metadata_document'
require 'caster/metadata/metadata_database'
require 'couchrest'

module Caster

  class Migrator

    def initialize metadata
      @dbs = {}
      @metadata = metadata
      Caster.log.info { "using #{metadata.desc} for storing metadata documents." }
    end
    
    def migrate_in_dir path, migrate_database = nil, max_version = nil

      all_migrations = {}

      path = path.sub /(\/)+$/, ''
      cast_files = Dir["#{path}/*.cast"]
      Caster.log.info { "found #{cast_files.length} migration scripts under #{path}:\n#{cast_files.to_yaml}" }

      cast_files.map do |file|
        migration_version, database = File.basename(file, '.cast').split '.'

        @dbs[database] = CouchRest.database! "http://#{Caster.config['host']}:#{Caster.config['port']}/#{database}" if @dbs[database] == nil

        all_migrations[database] = [] if all_migrations[database] == nil

        all_migrations[database] << {
            :current_version => @metadata.get_db_version(database),
            :version => migration_version,
            :filepath => file
        }
      end

      all_migrations.each_pair do |database, migrations|
        Caster.log.info { "#{'<' * 10} starting migrations for database #{database}" }
        Caster.log.info { "current database version: #{migrations.first[:current_version] || 'none' }" }

        db_filtered = (migrate_database == nil)? migrations.map : migrations.map do |migration|
          migration if migrate_database == database
        end.compact
        Caster.log.info { "no migration scripts found for database #{migrate_database}" } if migrate_database != nil and db_filtered.length == 0

        min_version_filtered = db_filtered.map do |migration|
          migration if migration[:current_version] == nil or migration[:version] > migration[:current_version]
        end.compact

        max_version_filtered = min_version_filtered.map do |migration|
          migration if max_version == nil or migration[:version] <= max_version
        end.compact

        filtered_and_sorted_files = max_version_filtered.map do |migration|
          migration[:filepath]
        end.sort
        Caster.log.info {( (filtered_and_sorted_files.length > 0)? "using migration scripts:\n#{ filtered_and_sorted_files.map{ |f| File.basename(f) }.to_yaml }" : "no applicable scripts found for database #{database}" )}

        filtered_and_sorted_files.each do |file|
          migrate_file file
        end

        Caster.log.info { (max_version_filtered.length > 0)? "#{'>' * 10} finished migrating database #{database} to version #{max_version_filtered.last[:version]}\n" : "did not run any migration on database #{database}\n" }
      end

    end

    def migrate_file path
      Caster.log.info { "#{'<' * 5} executing script #{File.basename(path)}" }

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
