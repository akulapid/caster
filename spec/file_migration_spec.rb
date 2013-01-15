require 'spec_helper'
require 'caster/migrator'

describe 'migrate caster script in file: ' do
  before do
    @res = "#{File.dirname(__FILE__)}/res/single_migration/000.foobar.add_name_to_foo.cast"
    @doc = @foobar.save_doc({ 'type' => 'foo' })
    @migrator = Migrator.new(@metadata = MetadataDocument.new)
  end

  it "should add metadoc with version" do
    @migrator.migrate_file @res

    @metadata.get_db_version('foobar').should == '000'
  end

  it "should not migrate to lower version" do
    @foobar.save_doc({
       'type' => 'caster_metadoc',
       'foobar' => '001'
    })

    lambda { @migrator.migrate_file @res }.should raise_exception
  end

  it "should update version" do
    @foobar.save_doc({
       'type' => 'caster_metadoc',
       'foobar' => '0'
    })

    @migrator.migrate_file @res

    @metadata.get_db_version('foobar').should == '000'
  end

  it "should add name all docs in foobar" do
    @migrator.migrate_file @res

    @foobar.get(@doc['id'])['name'].should == 'atilla'
  end
end