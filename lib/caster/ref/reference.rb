module Caster
  class Reference

    # to enable passing over method calls on the reference through method_missing
    Object.instance_methods.each do |m|
      undef_method m unless ['__send__', '__id__', 'object_id', 'is_a?'].include? m.to_s
    end

    def initialize db_handle, view, query
      rdocs = db_handle.view(view, query)['rows']
      @docs = rdocs.map { |rdoc| rdoc['doc'] or rdoc['value'] }
      @post_eval_calls = []
    end

    def where &predicate
      @predicate = predicate
      self
    end

    def method_missing method_name, *args
      @post_eval_calls << [method_name, args]
      self
    end

    def evaluate target_doc
      @docs.each do |doc|
        if @predicate.call doc
          value = deref(doc, @value_field)
          @post_eval_calls.each do |args|
            value = value.send args[0], *args[1]
          end
          return value
        end
      end
      nil
    end

    private
    def deref doc, accessor
      return doc if accessor == nil
      value = eval 'doc' << accessor.split('.').map { |field| "['#{field}']" }.join
      (value.is_a? Fixnum)? value : value.clone
    end
  end
end
