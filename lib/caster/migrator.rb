require 'caster/migration'
require 'couchrest'

module Caster

  class Migrator

    def migrate_db_in_dir database, path, max_version = nil
      db = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database}"

      current_version = nil
      begin
        current_version = db.get("#{Caster.config[:metadoc_id_prefix]}_#{database}")['version']
      rescue
        # ignored
      end

      path = path.sub /(\/)+$/, ''

      migrations = Dir["#{path}/*.cast"].map do |file|
        version, db_in_filename = File.basename(file, '.cast').split '.'
        { :version => version , :database => db_in_filename, :filepath => file }
      end

      db_filtered = migrations.map do |migration|
        migration if database == migration[:database]
      end.compact

      min_version_filtered = db_filtered.map do |migration|
        migration if current_version == nil or migration[:version] > current_version
      end.compact

      max_version_filtered = min_version_filtered.map do |migration|
        migration if max_version == nil or migration[:version] <= max_version
      end.compact

      filtered_and_sorted_files = max_version_filtered.map do |migration|
        migration[:filepath]
      end.sort

      filtered_and_sorted_files.each do |file|
        migrate_file file, db
      end
    end

    def migrate_all_in_dir path

      dbs = {}
      all_migrations = {}

      path = path.sub /(\/)+$/, ''
      Dir["#{path}/*.cast"].map do |file|
        migration_version, database = File.basename(file, '.cast').split '.'

        dbs[database] = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database}" if dbs[database] == nil

        current_version = nil
        begin
          current_version = dbs[database].get("#{Caster.config[:metadoc_id_prefix]}_#{database}")['version']
        rescue
          # ignored
        end

        all_migrations[database] = [] if all_migrations[database] == nil

        all_migrations[database] << {
            :current_version => current_version,
            :version => migration_version,
            :filepath => file
        }
      end

      all_migrations.each_pair do |database, migrations|

        min_version_filtered = migrations.map do |migration|
          migration if migration[:current_version] == nil or migration[:version] > migration[:current_version]
        end.compact

        filtered_and_sorted_files = min_version_filtered.map do |migration|
          migration[:filepath]
        end.sort

        filtered_and_sorted_files.each do |file|
          migrate_file file, dbs[database]
        end
      end

    end

    def migrate_file path, db_handle = nil
      filename = File.basename path, '.cast'
      version, database = filename.split '.'

      db = db_handle || (CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database}")
      metadoc = nil
      begin
        metadoc = db.get "#{Caster.config[:metadoc_id_prefix]}_#{database}"
      rescue
        metadoc = {
            '_id' => "#{Caster.config[:metadoc_id_prefix]}_#{database}",
            'type' => "#{Caster.config[:metadoc_type]}"
        }
      end

      if metadoc['version'] != nil and version <= metadoc['version']
        raise 'Cannot migrate down!'
      else
        metadoc['version'] = version
      end

      migrate_script database, File.open(path).read

      db.save_doc metadoc
    end
  end
end