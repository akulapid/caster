require 'caster/accessor'

module Caster
  class Remove

    def initialize field
      @field = field
      @accessor = Accessor.new
    end

    def execute doc
      @accessor.delete doc, @field
      doc
    end
  end
end