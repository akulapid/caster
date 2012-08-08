require 'caster/execution'

module Caster

  def migrate database_name, &block
    @database_name = database_name
    yield
    @database_name = nil
  end

  def over scope, query = {}, &block
    database_name, view = split(scope)
    Execution.new(database_name || @database_name, view, query, &block).execute
  end

  def split scope
    if scope.count('/') == 1
      return nil, scope
    elsif scope.count('/') == 2
      return scope.split('/', 2)
    end
  end
end