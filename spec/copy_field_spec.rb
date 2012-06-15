require 'spec_helper'
require 'migration'
require 'migrator'
require 'couchrest'

describe 'copy field from one doc type to another: ' do
  before do
    @foo_doc1 = @foobar.save_doc({ 'type' => 'foo' })
    @foo_doc2 = @foobar.save_doc({ 'type' => 'foo' })
    @foo_doc3 = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc1 = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo_id' => @foo_doc1['id'] })
    @fuu_doc2 = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'genghis', 'foo_id' => @foo_doc2['id'] })

    class CopyName < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          add 'name', query('foobar/all_fuu').linked_by('foo_id').field('name')
        end
      end
    end
    Migrator.run CopyName
  end

  it "should add name to all foos from their respective fuus" do
    @foobar.get(@foo_doc1['id'])['name'].should == 'attila'
    @foobar.get(@foo_doc2['id'])['name'].should == 'genghis'
  end

  it "should not update name if doc does not have a linked fuu" do
    @foobar.get(@foo_doc3['id'])['name'].should == nil
  end
end