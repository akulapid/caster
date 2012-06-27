require 'couchrest'
require 'ref/reference'

class CrossReference < Reference

  def initialize db_handle, view, query
    rdocs = db_handle.view(view, query)['rows']
    @docs = rdocs.map { |rdoc| rdoc['value'] }
    self
  end

  def linked_by field
    @linked_field = field
    self
  end

  def field field
    @value_field = field
    self
  end

  def execute target_doc
    @docs.each do |doc|
      if access_field(doc, @linked_field) == target_doc['_id']
        return (@value_field == nil)? doc : access_field(doc, @value_field)
      end
    end
    nil
  end
end