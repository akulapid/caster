module Caster
  class Clone

    def initialize ref
      @ref = ref
    end

    def execute doc
      doc.delete '_rev'
      @ref.execute doc
    end
  end
end