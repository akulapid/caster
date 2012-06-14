class Migrator

  def self.run migration
    if migration.view_name == nil
      rdocs = migration.db.all_docs('include_docs' => 'true')['rows']
    else
      rdocs = migration.db.view(migration.view_name, migration.query_params)['rows']
    end

    docs = []
    rdocs.each do |rdoc|
      doc = (migration.view_name == nil)? rdoc['doc'] : rdoc['value']
      migration.up_operations.each do |op|
        doc = op.execute doc
      end
      docs << doc
    end
    migration.db.bulk_save docs
  end
end