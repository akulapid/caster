require 'caster/execution'

module Caster

  class Migration

    def self.on_database name
      @db = CouchRest.database "http://#{Caster.config[:host]}:#{Caster.config[:port]}/#{name}"
    end

    def self.up
      @up_executions = []
      @current_executions = @up_executions
      yield
    end

    def self.up_executions
      @up_executions
    end

    def self.over_scope view, query = {}, &block
      @current_executions << Execution.new(@db, view, query, &block)
    end
  end
end