require 'caster/migration'
require 'couchrest'

module Caster

  class Migrator

    def migrate_file path
      filename = File.basename path, '.cast'
      version, database = filename.split '.'

      db = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database}"
      begin
        @metadoc = db.get "#{Caster.config[:metadoc_id_prefix]}_#{database}"
      rescue
        @metadoc = {
            '_id' => "#{Caster.config[:metadoc_id_prefix]}_#{database}",
            'type' => "#{Caster.config[:metadoc_type]}"
        }
      end

      if @metadoc['version'] != nil and version <= @metadoc['version']
        raise 'Cannot migrate down!'
      else
        @metadoc['version'] = version
      end

      migrate_script database, File.open(path).read

      db.save_doc @metadoc
    end
  end
end