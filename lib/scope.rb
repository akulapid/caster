require 'couchrest'

# defines an execution scope which is a set of documents over which migration operations run
class Scope

  def initialize database_name, view, query
    @db = CouchRest.database "http://127.0.0.1:5984/#{database_name}"
    @view = view
    @query = query
    @operations = []
  end

  def add_operation operation
    @operations << operation
  end

  def execute
    if @view == nil
      rdocs = @db.all_docs('include_docs' => 'true')['rows']
    else
      rdocs = @db.view(@view, @query)['rows']
    end

    docs = []
    rdocs.each do |rdoc|
      doc = (@view == nil)? rdoc['doc'] : rdoc['value']
      @operations.each do |op|
        doc = op.execute doc
      end
      docs << doc
    end
    @db.bulk_save docs
  end
end