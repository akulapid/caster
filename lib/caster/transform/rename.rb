require 'caster/accessor'

module Caster
  class Rename

    def initialize old_name, new_name
      @old_name = old_name
      @new_name = new_name
      @accessor = Accessor.new
    end

    def execute doc
      doc[@new_name] = doc[@old_name]
      @accessor.set(doc, @new_name, @accessor.get(doc, @old_name))
      @accessor.delete doc, @old_name
      doc
    end
  end
end