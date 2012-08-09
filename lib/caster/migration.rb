require 'caster/execution'

module Caster

  def migrate database_name, &block
    @database_name = database_name
    yield
    @database_name = nil
  end

  def migrate_script database_name, code
    migrate database_name do
      self.instance_eval code, __FILE__, __LINE__
    end
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