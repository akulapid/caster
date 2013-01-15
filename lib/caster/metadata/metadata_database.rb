require 'caster/metadata/metadata_store'
require 'couchrest'

module Caster

  class MetadataDatabase

    include Caster::MetadataStore

    def initialize
      @metadb = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{Caster.config[:metadata][:database]}"
    end

    def desc
      'external database'
    end

    def get_db_version database
      get_metadoc(@metadb)[database] rescue nil
    end

    def save_db_version database, version
      metadoc = get_metadoc(@metadb)
      metadoc[database] = version
      @metadb.save_doc metadoc
    end
  end
end
