class Add

  def initialize field, value
    @field = field
    @value = value
  end

  def execute doc
    doc[@field] = @value
    doc
  end
end