require 'couchrest'

class Add

  def initialize field, value
    @field = field
    @value = value
  end

  def execute doc
    doc[@field] = evaluate(@value, doc)
    doc
  end

  def evaluate obj, target_doc
    (obj.class == Query)? obj.execute(target_doc) : obj
  end
end