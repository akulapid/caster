require 'caster/execution'

module Caster

  def over view, query = {}, &block
    Execution.new(view, query, &block).execute
  end
end