require 'couchrest'
require 'operation'
require 'transform/add'
require 'transform/remove'
require 'transform/rename'
require 'transform/create'
require 'transform/delete'
require 'transform/clone'
require 'ref/cross_reference'
require 'ref/self_reference'

# defines an execution scope which is a set of documents over which migration operations run
class Execution

  def initialize database_name, view, query, &block
    @database_name = database_name
    @db = CouchRest.database "http://127.0.0.1:5984/#{database_name}"
    @view = view
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

  def create_on database_name, params
    @operations << Operation.new(CouchRest.database("http://127.0.0.1:5984/#{database_name}"), Clone.new(params))
  end

  def query scope, query = {}
    CrossReference.new @database_name, scope, query
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