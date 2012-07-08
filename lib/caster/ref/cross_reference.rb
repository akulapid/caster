require 'couchrest'
require 'caster/ref/reference'

module Caster

  class CrossReference < Reference

    def initialize db_handle, scope, query
      view, @value_field = scope.split('#', 2)
      rdocs = db_handle.view(view, query)['rows']
      @docs = rdocs.map { |rdoc| rdoc['value'] }
      self
    end

    def linked_by field
      @linked_field = field
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
end
