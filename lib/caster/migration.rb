require 'caster/execution'

module Caster

  class Migration

    def self.on_database name
      @database_name = name
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
      @current_executions << Execution.new(@database_name, view, query, &block)
    end
  end
end