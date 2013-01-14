require 'caster/accessor'

module Caster
  class Reference

    # to enable passing over method calls on the reference through method_missing
    Object.instance_methods.each do |m|
      undef_method m unless ['__send__', '__id__', 'object_id', 'is_a?'].include? m.to_s
    end

    def initialize docs
      @docs = docs
      @method_chain = []
      @accessor = Accessor.new
    end

    def where &predicate
      @predicate = predicate
      self
    end

    def method_missing method_name, *args
      @method_chain << [method_name, args]
      self
    end

    def evaluate target_doc
      @docs.each do |doc|
        if @predicate.call doc
          value = @accessor.get doc, @value_field
          @method_chain.each do |args|
            value = value.send args[0], *args[1]
          end
          return value
        end
      end
      nil
    end
  end
end
