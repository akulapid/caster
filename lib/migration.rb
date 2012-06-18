require 'scope'

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

  def self.over_scope view, query = {}, &block
    @current_scopes << Scope.new(@database_name, view, query, &block)
  end
end