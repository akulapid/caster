class Rename

  def initialize old_name, new_name
    @old_name = old_name
    @new_name = new_name
  end

  def execute doc
    doc[@new_name] = doc[@old_name]
    doc.delete @old_name
    doc
  end
end