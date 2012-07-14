module Caster
  class Reference

    # to enable passing over method calls on the reference through method_missing
    Object.instance_methods.each do |m|
      undef_method m unless ['__send__', '__id__', 'object_id', 'is_a?'].include? m.to_s
    end

    def initialize db_handle, scope, query
      view, @value_field = scope.split('#', 2)
      rdocs = db_handle.view(view, query)['rows']
      @docs = rdocs.map { |rdoc| rdoc['value'] }
      @post_eval_operation = []
    end

    def linked_by field
      @linked_field = field
      self
    end

    def method_missing method_name, *args
      @post_eval_operation << [method_name, args]
      self
    end

    def evaluate target_doc
      @docs.each do |doc|
        if deref(doc, @linked_field) == target_doc['_id']
          if @value_field == nil
            return doc
          else
            value = deref doc, @value_field
            @post_eval_operation.each do |op|
              value = value.send op[0], *op[1]
            end
            return value
          end
        end
      end
      nil
    end

    private
    def deref doc, accessor
      value = eval 'doc' << accessor.split('.').map { |field| "['#{field}']" }.join
      (value.is_a? Fixnum)? value : value.clone
    end
  end
end
