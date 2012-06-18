# a migration operation applies a transformation over a document and saves it to a database
class Operation

  def initialize db_handle, transformation
    @db_handle = db_handle
    @transformation = transformation
  end

  def db_handle
    @db_handle
  end

  def transformation
    @transformation
  end
end