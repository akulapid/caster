module Caster
  class Clone

    def initialize source
      @source = source
    end

    def execute doc
      @source.delete '_rev'
      @source
    end
  end
end