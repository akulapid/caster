require 'couchrest'

module Caster

  class MetadataDocument

    def get_db_version database
      db = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database}"
      begin
        return db.get("#{Caster.config[:metadata][:id_prefix]}_#{database}")['version']
      rescue
        # ignored
      end
      nil
    end

    def save_db_version database, version
      db = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database}"
      metadoc = nil
      begin
        metadoc = db.get "#{Caster.config[:metadata][:id_prefix]}_#{database}"
      rescue
        metadoc = {
            '_id' => "#{Caster.config[:metadata][:id_prefix]}_#{database}",
            'type' => "#{Caster.config[:metadata][:type]}"
        }
      end
      metadoc['version'] = version
      db.save_doc metadoc
    end
  end
end
