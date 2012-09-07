module Caster

  # provides means to easily access nested values from hash
  # doc['a']['b']['c'] can be accessed as 'a.b.c'
  # doc['a.b'] can be accessed as 'a\.b'
  # doc['a\b'] can be accessed as 'a\\\\b'
  class Accessor

    def get doc, accessor
      return doc if accessor == nil
      value = eval(access('doc', accessor))
      (value.is_a? Fixnum)? value : value.clone
    end

    def set doc, accessor, value
      sub_doc = doc
      split(accessor).each do |sub_field|
        sub_doc[sub_field] = {} if sub_doc[sub_field] == nil
        sub_doc = sub_doc[sub_field]
      end
      eval("#{access('doc', accessor)} = value")
    end

    def delete doc, accessor
      sub_fields = split(accessor)
      field_to_delete = sub_fields.pop
      eval("#{access('doc', sub_fields.join('.'))}.delete('#{field_to_delete}')")
    end

    def access doc_var, accessor
      doc_var << split(accessor).map { |field| "['#{field}']" }.join
    end

    def split accessor
      escape = false
      words = []
      w = 0
      (0..accessor.length - 1).each do |i|

        c = accessor[i].chr
        n = accessor[i+1].chr rescue ''

        if escape
          escape = false
          next
        end

        words[w] = '' if words[w] == nil

        if c == '\\'
          words[w] << n
          escape = true
          next
        end

        if c == '.'
          w = w + 1
          next
        end

        words[w] << c
      end
      words
    end
  end
end
