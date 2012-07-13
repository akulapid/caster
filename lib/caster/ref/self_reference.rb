#require 'caster/ref/reference'

module Caster

  class SelfReference < Reference

    def initialize accessor
      super()
      @accessor = accessor
    end

    def execute target_doc
      (@accessor == nil)? target_doc.clone : access_field(target_doc, @accessor)
    end
  end
end
