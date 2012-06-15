require 'scope'
require 'add'
require 'remove'

class Migration

  def self.on_database name
    @database_name = name
  end

  def self.up
    @up_scopes = []
    @current_scopes = @up_scopes
    yield
  end

  def self.up_executions
    @up_scopes
  end

  def self.over_scope view, query = {}
    @current_scopes << Scope.new(@database_name, view, query)
    yield
  end

  def self.add field, value
    @current_scopes.last.add_operation(Add.new(field, value))
  end

  def self.remove field
    @current_scopes.last.add_operation(Remove.new(field))
  end
end