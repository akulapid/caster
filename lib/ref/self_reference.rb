require 'ref/reference'

class SelfReference < Reference

  def initialize accessor
    @accessor = accessor
  end

  def execute target_doc
    (@accessor == nil)? target_doc.clone : access_field(target_doc, @accessor)
  end
end