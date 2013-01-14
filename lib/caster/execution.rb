require 'couchrest'
require 'caster/operation'
require 'caster/transform/add'
require 'caster/transform/remove'
require 'caster/transform/rename'
require 'caster/transform/create'
require 'caster/transform/delete'
require 'caster/transform/clone'
require 'caster/reference'

module Caster

  # defines an execution scope which is a set of documents over which migration operations run
  class Execution

    def initialize db, view, query, &block
      @db = db
      @view = view
      @query = query
      @ref_docs_cache = {}
      @block = block
    end

    def add field, value
      @operations << Operation.new(@db, Add.new(field, value))
    end
    alias_method :update, :add

    def remove field
      @operations << Operation.new(@db, Remove.new(field))
    end

    def rename old_name, new_name
      @operations << Operation.new(@db, Rename.new(old_name, new_name))
    end

    def create params
      @operations << Operation.new(@db, Create.new(params))
    end

    def delete
      @operations << Operation.new(@db, Delete.new)
    end

    def create_on db_handle, params
      @operations << Operation.new(db_handle, Clone.new(params))
    end

    def from scope, query = {}
      if scope.scan('/').length == 1
        view = scope
        db = @db
      else
        database_name, view = scope.split('/', 2)
        db = CouchRest.database "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database_name}"
      end
      key = [scope, query]
      @ref_docs_cache[key] = db_query(db, view, query)['rows'].map { |rdoc| rdoc['doc'] || rdoc['value'] } unless @ref_docs_cache.has_key? key
      Reference.new @ref_docs_cache[key]
    end

    def execute
      limit = @query['limit'] || 1.0/0.0
      if Caster.config[:batch_size] == nil or limit < Caster.config[:batch_size]
        execute_batch db_query(@db, @view, @query)['rows']
        return
      end

      @query['limit'] = Caster.config[:batch_size] + 1
      saved_docs = 0
      while saved_docs < limit do
        docs = db_query(@db, @view, @query)['rows']
        return if docs.length == 0

        @query['startkey_docid'] = docs.last['id']
        @query['startkey'] = docs.last['key']

        if docs.length <= Caster.config[:batch_size]
          execute_batch docs
          return
        elsif saved_docs + docs.length - 1 > limit
          execute_batch docs.slice(0, limit - saved_docs)
          return
        else
          docs.pop
          execute_batch docs
          saved_docs += docs.length
        end
      end
    end

    private
    def db_query db, view, params
      Caster.log.info { "fetching from '#{db.name}' over '#{view}' with #{params.inspect}" }
      db.view view, params
    end

    def execute_batch docs
      db_docs_map = Hash.new { |k, v| k[v] = [] }

      docs.each do |rdoc|
        doc = rdoc.has_key?('doc')? rdoc['doc'] : rdoc['value']

        @operations = []
        instance_exec doc.clone, &@block
        @operations.each do |op|
          db_docs_map[op.db_handle] << op.transformation.execute(doc)
        end
      end
      db_docs_map.each do |db, db_docs|
        db.bulk_save db_docs
        Caster.log.info { "wrote #{db_docs.length} doc#{(db_docs.length > 1)? 's' : '' } to #{db.name}" }
      end
    end

  end
end
