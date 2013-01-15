require 'caster/metadata/metadata_store'
require 'couchrest'

module Caster

  class MetadataDocument

    include Caster::MetadataStore

    def desc
      'source database'
    end

    def get_db_version database
      db = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database}"
      get_metadoc(db)[db.name] rescue nil
    end

    def save_db_version database, version
      db = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database}"
      metadoc = get_metadoc(db)
      metadoc[database] = version
      db.save_doc metadoc
    end
  end
end
