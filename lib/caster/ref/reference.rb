module Caster
  class Reference

    def initialize
      @post_eval_operation = []
    end

    def method_missing method_name, *args
      @post_eval_operation << [method_name, args]
      self
    end

    protected
    def access_field doc, accessor
      value = eval('doc' << accessor.split('.').map { |field| "['#{field}']" }.join)
      ret_value = (value.is_a? Fixnum)? value : value.clone
      (@post_eval_operation || []).each do |op|   # TODO: initialize post_eval_operation
        ret_value.send op[0], *op[1]
      end
      ret_value
    end
  end
end
