require 'couchrest'
require 'add'

class Migration

  def self.on_database name
    @db = CouchRest.database "http://127.0.0.1:5984/#{name}"
  end

  def self.over_view name
    @view_name = name
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

  def self.operations
    @operations
  end

  def self.add field, value
    @operations << Add.new(field, value)
  end
end