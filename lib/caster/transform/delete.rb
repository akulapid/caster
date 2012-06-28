module Caster
  class Delete

    def execute doc
      doc.merge '_deleted' => true
    end
  end
end