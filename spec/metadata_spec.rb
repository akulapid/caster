require 'spec_helper'
require 'caster/migrator'

describe "store metadata doc in source database: " do

  before do
    Caster.config['metadata'] = {
      'design_doc_id' => 'caster_meta',
      'key' => {
          'type' => 'caster_metadoc'
      }
    }

    @foobar.save_doc({ 'type' => 'foo' })

    @res = "#{File.dirname(__FILE__)}/res/multiple_migrations"
    @migrator = Migrator.new MetadataDocument.new
  end

  it "should create metadata design doc" do
    @migrator.migrate_in_dir @res, 'foobar'

    @foobar.get('_design/caster_meta').should_not == nil
  end

  it "should update revision" do
    @migrator.migrate_in_dir @res, 'foobar'

    metadoc = @foobar.view('caster_meta/meta_doc')['rows'][0]['value']
    metadoc['type'].should == 'caster_metadoc'
    metadoc['foobar'].should == '001'
  end

  it "should create only 1 meta_doc" do
    @migrator.migrate_in_dir @res, 'foobar'

    @foobar.view('caster_meta/meta_doc')['rows'].size.should == 1
  end
end

describe "store metadata doc in it's dedicated database: " do

  before do
    Caster.config['metadata'] = {
      'database' => 'caster_metadb',
      'design_doc_id' => 'caster_meta',
      'key' => {
          'type' => 'caster_metadoc'
      }
    }

    @foobar.save_doc({ 'type' => 'foo' })

    @res = "#{File.dirname(__FILE__)}/res/multiple_migrations"
    @migrator = Migrator.new MetadataDatabase.new
    @metadb = CouchRest.database! "http://#{Caster.config['host']}:#{Caster.config['port']}/caster_metadb"
  end

  it "should create metadata design doc" do
    @migrator.migrate_in_dir @res, 'foobar'

    @metadb.get('_design/caster_meta').should_not == nil
  end

  it "should update revision" do
    @migrator.migrate_in_dir @res, 'foobar'

    metadoc = @metadb.view('caster_meta/meta_doc')['rows'][0]['value']
    metadoc['type'].should == 'caster_metadoc'
    metadoc['foobar'].should == '001'
  end

  after do
    @metadb.delete!
    Caster.config['metadata']['database'] = nil
  end
end
