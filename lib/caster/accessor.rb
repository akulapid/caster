module Caster

  # provides means to easily access nested values from hash
  # doc['a']['b']['c'] can be accessed as 'a.b.c'
  class Accessor

    def get doc, accessor
      return doc if accessor == nil
      value = eval(access('doc', accessor))
      (value.is_a? Fixnum)? value : value.clone
    end

    def set doc, accessor, value
      sub_doc = doc
      accessor.split('.').each do |sub_field|
        sub_doc[sub_field] = {} if sub_doc[sub_field] == nil
        sub_doc = sub_doc[sub_field]
      end
      eval("#{access('doc', accessor)} = value")
    end

    def delete doc, accessor
      sub_fields = accessor.split('.')
      field_to_delete = sub_fields.pop
      eval("#{access('doc', sub_fields.join('.'))}.delete('#{field_to_delete}')")
    end

    private
    def access doc_var, accessor
      doc_var << accessor.split('.').map { |field| "['#{field}']" }.join
    end
  end
end
