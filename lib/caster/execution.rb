require 'couchrest'
require 'caster/operation'
require 'caster/transform/add'
require 'caster/transform/remove'
require 'caster/transform/rename'
require 'caster/transform/create'
require 'caster/transform/delete'
require 'caster/transform/clone'
require 'caster/ref/reference'

module Caster

  # defines an execution scope which is a set of documents over which migration operations run
  class Execution

    def initialize database_name, view, query, &block
      @db = CouchRest.database "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database_name}"
      @view = view
      @query = query
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
        return Reference.new @db, scope, query
      else
        database_name, view = scope.split('/', 2)
        db = CouchRest.database "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database_name}"
        return Reference.new db, view, query
      end
    end

    def execute
      rdocs = @db.view(@view, @query)['rows']
      db_docs_map = Hash.new { |k, v| k[v] = [] }
      rdocs.each do |rdoc|
        doc = rdoc.has_key?('doc')? rdoc['doc'] : rdoc['value']

        @operations = []
        instance_exec doc.clone, &@block
        @operations.each do |op|
          db_docs_map[op.db_handle] << op.transformation.execute(doc)
        end
      end
      db_docs_map.each do |db, docs|
        db.bulk_save docs
      end
    end
  end
end