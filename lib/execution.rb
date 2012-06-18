require 'couchrest'
require 'op/add'
require 'op/remove'
require 'op/rename'
require 'op/create'
require 'op/delete'
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
    @operations << Add.new(field, value)
  end
  alias_method :update, :add

  def remove field
    @operations << Remove.new(field)
  end

  def rename old_name, new_name
    @operations << Rename.new(old_name, new_name)
  end

  def create params
    @operations << Create.new(params)
  end

  def delete
    @operations << Delete.new
  end

  def query scope, query = {}
    CrossReference.new @database_name, scope, query
  end

  def doc accessor = nil
    SelfReference.new accessor
  end

  def execute
    rdocs = @db.view(@view, @query)['rows']
    docs = []
    rdocs.each do |rdoc|
      doc = rdoc['value']
      @operations.each do |op|
        doc = op.execute doc
      end
      docs << doc
    end
    @db.bulk_save docs
  end  
end