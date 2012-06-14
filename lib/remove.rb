class Remove

  def initialize field
    @field = field
  end

  def execute doc
    doc.delete @field
    doc
  end
end