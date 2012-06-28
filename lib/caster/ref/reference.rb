module Caster
  class Reference
    protected
    def access_field doc, accessor
      eval 'doc' << accessor.split('.').map { |field| "['#{field}']" }.join
    end
  end
end
