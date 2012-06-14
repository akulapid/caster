require 'couchrest'
require 'add'
require 'remove'

class Migration

  def self.on_database name
    @foobar = CouchRest.database "http://127.0.0.1:5984/#{name}"
  end

  def self.over_scope name, query_params = {}
    @view_name = name
    @query_params = query_params
  end

  def self.up
    @up_operations = []
    @current_operations = @up_operations
    yield
  end

  def self.db
    @foobar
  end

  def self.view_name
    @view_name
  end

  def self.query_params
    @query_params
  end

  def self.up_operations
    @up_operations
  end

  def self.add field, value
    @current_operations << Add.new(field, value)
  end

  def self.remove field
    @current_operations << Remove.new(field)
  end
end