module Caster
  class Reference

    # to enable passing over method calls on the reference through method_missing
    Object.instance_methods.each do |m|
      undef_method m unless ['__send__', '__id__', 'object_id', 'is_a?'].include? m.to_s
    end

    def initialize
      @post_eval_operation = []
    end

    def method_missing method_name, *args
      @post_eval_operation << [method_name, args]
      self
    end

    protected
    def access_field doc, accessor
      value = eval 'doc' << accessor.split('.').map { |field| "['#{field}']" }.join
      (value.is_a? Fixnum)? value : value.clone
    end

    def access_field_with_tail doc, accessor
      value = access_field doc, accessor
      (@post_eval_operation || []).each do |op|   # TODO: initialize post_eval_operation
        value = value.send op[0], *op[1]
      end
      value
    end
  end
end
