require 'couchrest'
require 'caster/operation'
require 'caster/transform/add'
require 'caster/transform/remove'
require 'caster/transform/rename'
require 'caster/transform/create'
require 'caster/transform/delete'
require 'caster/transform/clone'
require 'caster/ref/cross_reference'
require 'caster/ref/self_reference'

module Caster

  # defines an execution scope which is a set of documents over which migration operations run
  class Execution

    def initialize scope, query, &block
      database_name, @view = scope.split('/', 2)
      @db = CouchRest.database "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database_name}"
      @query = query
      @operations = []
      instance_eval &block
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

    def query scope, query = {}
      CrossReference.new @db, scope, query
    end

    def doc accessor = nil
      SelfReference.new accessor
    end

    def execute
      rdocs = @db.view(@view, @query)['rows']
      db_docs_map = Hash.new { |k, v| k[v] = [] }
      rdocs.each do |rdoc|
        doc = rdoc['value']
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