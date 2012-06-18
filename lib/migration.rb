require 'scope'
require 'op/add'
require 'op/remove'
require 'op/rename'
require 'op/create'
require 'op/delete'
require 'ref/cross_reference'
require 'ref/self_reference'

class Migration

  def self.on_database name
    @database_name = name
  end

  def self.up
    @up_scopes = []
    @current_scopes = @up_scopes
    yield
  end

  def self.up_scopes
    @up_scopes
  end

  def self.over_scope view, query = {}
    @current_scopes << Scope.new(@database_name, view, query)
    yield
  end

  def self.query scope, query = {}
    CrossReference.new @database_name, scope, query
  end

  def self.field accessor
    SelfReference.new accessor
  end

  def self.add field, value
    @current_scopes.last.add_operation(Add.new(field, value))
  end

  class << self
    alias_method :update, :add
  end

  def self.remove field
    @current_scopes.last.add_operation(Remove.new(field))
  end

  def self.rename old_name, new_name
    @current_scopes.last.add_operation(Rename.new(old_name, new_name))
  end

  def self.create params
    @current_scopes.last.add_operation(Create.new(params))
  end

  def self.delete
    @current_scopes.last.add_operation(Delete.new)
  end
end