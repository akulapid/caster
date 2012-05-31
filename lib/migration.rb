require 'couchrest'
require 'add'

class Migration

  def self.on_database name
    @db = CouchRest.database "http://127.0.0.1:5984/#{name}"
  end

  def self.over_scope name, query_params = {}
    @view_name = name
    @query_params = query_params
  end

  def self.up
    @operations = []
    yield
  end

  def self.db
    @db
  end

  def self.view_name
    @view_name
  end

  def self.query_params
    @query_params
  end

  def self.operations
    @operations
  end

  def self.add field, value
    @operations << Add.new(field, value)
  end
end