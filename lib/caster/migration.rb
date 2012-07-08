require 'caster/execution'

module Caster

  def over_scope view, query = {}, &block
    Execution.new(view, query, &block).execute
  end
end