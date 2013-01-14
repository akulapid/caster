require 'couchrest'
module Caster

  class MetadataDatabase

    def desc
      'external database'
    end

    def get_db_version database
      db = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{Caster.config[:metadata][:database]}"
      begin
        return db.get(database)[:version]
      rescue
        # ignored
      end
    end

    def save_db_version database, version
      db = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{Caster.config[:metadata][:database]}"
      metadoc = db.get(database)
      metadoc['version'] = version
      db.save_doc metadoc
    end
  end
end
