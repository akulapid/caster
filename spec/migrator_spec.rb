require 'spec_helper'
require 'caster/migrator'

describe 'migrate caster script in file: ' do
  before do
    @res = "#{File.dirname(__FILE__)}/res/000.foobar.add_name_to_foo.cast"
    @doc = @foobar.save_doc({ 'type' => 'foo' })
  end

  it "should add metadoc with version" do
    Migrator.new.migrate_file @res

    @foobar.get('caster_foobar')['version'].should == '000'
  end

  it "should not migrate to lower version" do
    @foobar.save_doc({
      '_id' => 'caster_foobar',
      'type' => 'caster_metadoc',
      'version' => '001'
    })

    lambda { Migrator.new.migrate_file @res }.should raise_exception
  end

  it "should update version" do
    @foobar.save_doc({
        '_id' => 'caster_foobar',
        'type' => 'caster_metadoc',
        'version' => '0'
    })

    Migrator.new.migrate_file @res

    @foobar.get('caster_foobar')['version'].should == '000'
  end

  it "should add name all docs in foobar" do
    Migrator.new.migrate_file @res

    @foobar.get(@doc['id'])['name'].should == 'atilla'
  end
end