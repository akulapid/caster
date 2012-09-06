require 'couchrest'
require 'caster/accessor'

module Caster
  class Add

    def initialize field, value
      @field = field
      @value = value
      @accessor = Accessor.new
    end

    def execute doc
      @accessor.set doc, @field, evaluate(@value, doc)
      doc
    end

    def evaluate obj, target_doc
      (obj.is_a? Reference)? obj.evaluate(target_doc) : obj
    end
  end
end