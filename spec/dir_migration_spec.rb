require 'spec_helper'
require 'caster/migrator'

describe 'migrate caster script in file: ' do
  before do
    @res = "#{File.dirname(__FILE__)}/res/multiple_migrations"
    @doc = @foobar.save_doc({ 'type' => 'foo' })
  end

  it "should migrations 000, 0001, 001" do
    Migrator.new.migrate_dir 'foobar', @res

    @foobar.get(@doc['id'])['name'].should == 'atilla'
    @foobar.get(@doc['id'])['class'].should == 'hun'
    @foobar.get(@doc['id'])['title'].should == 'warrior'
  end

  it "should update revision" do
    Migrator.new.migrate_dir 'foobar', @res

    @foobar.get('caster_foobar')['version'].should == '001'
  end

  it "should not run migration 000" do
    @foobar.save_doc({
         '_id' => 'caster_foobar',
         'type' => 'caster_metadoc',
         'version' => '000'
    })

    Migrator.new.migrate_dir 'foobar', @res

    @foobar.get(@doc['id'])['name'].should == nil
    @foobar.get(@doc['id'])['class'].should == 'hun'
    @foobar.get(@doc['id'])['title'].should == 'warrior'
  end

  it "should run migrations upto 0001 only" do
    Migrator.new.migrate_dir 'foobar', @res, '0001'

    @foobar.get(@doc['id'])['name'].should == 'atilla'
    @foobar.get(@doc['id'])['class'].should == 'hun'
    @foobar.get(@doc['id'])['title'].should == nil
  end

  it "should not run fuubar migrations" do
    Migrator.new.migrate_dir 'foobar', @res

    @foobar.get(@doc['id'])['oops'].should == nil
  end
end