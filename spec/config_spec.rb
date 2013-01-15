require 'spec_helper'
require 'caster/migrator'

describe 'config: ' do
  it 'should use host and port values from config' do
    Caster.configure({ 'host' => 'host', 'port' => 'port' })

    CouchRest.should_receive('database').with('http://host:port/foobar')

    migrate 'foobar' do
    end
  end

  context 'read config from yaml file' do
    before do
      @res = "#{File.dirname(__FILE__)}/res"
      Caster.configure_with "#@res/caster.yml"

      @doc = @foobar.save_doc({ 'type' => 'foo' })
    end

    it 'should add name to foo' do
      Migrator.new(MetadataDocument.new).migrate_in_dir "#@res/single_migration", 'foobar'

      @foobar.get(@doc['id'])['name'].should == 'atilla'
    end
  end
end
