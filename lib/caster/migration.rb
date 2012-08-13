require 'caster/execution'

module Caster

  def migrate database_name, &block
    @db = CouchRest.database "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database_name}"
    yield
    @db = nil
  end

  def migrate_script database_name, code
    migrate database_name do
      self.instance_eval code, __FILE__, __LINE__
    end
  end

  def over scope, query = {}, &block
    database_name, view = split(scope)
    db = CouchRest.database "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{database_name}" if @db == nil
    Execution.new(db || @db, view, query, &block).execute
  end

  def split scope
    if scope.count('/') == 1
      return nil, scope
    elsif scope.count('/') == 2
      return scope.split('/', 2)
    end
  end

  # fall down to couchrest methods
  def method_missing method_name, *args
    if @db.respond_to? method_name
      @db.send method_name, *args
    else
      super
    end
  end
end