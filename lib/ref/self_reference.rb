require 'ref/reference'

class SelfReference < Reference

  def initialize accessor
    @accessor = accessor
  end

  def execute target_doc
    access_field(target_doc, @accessor)
  end
end