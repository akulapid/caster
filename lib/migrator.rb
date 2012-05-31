class Migrator

  def self.run migration
    rdocs = migration.db.view(migration.view_name)['rows']
    docs = []
    rdocs.each do |rdoc|
      doc = rdoc["value"]
      migration.operations.each do |op|
        doc = op.execute doc
      end
      docs << doc
    end
    migration.db.bulk_save docs
  end
end