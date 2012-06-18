require 'spec_helper'

describe 'refer field within the same document: ' do
  before do
    @doc = @foobar.save_doc({ 'type' => 'foo', 'name' => 'attila', 'stats' => { 'score' => 5 }})

    class UpdateName < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          add 'title', doc('name')
          add 'victories', doc('stats.score')
        end
      end
    end
    Migrator.run UpdateName
  end

  it "should refer and add name" do
    @foobar.get(@doc['id'])['name'].should == 'attila'
  end

  it "should refer and add nested field score" do
    @foobar.get(@doc['id'])['victories'].should == 5
  end
end

describe 'refer field from another doc type: ' do
  before do
    @foo_doc1 = @foobar.save_doc({ 'type' => 'foo' })
    @foo_doc2 = @foobar.save_doc({ 'type' => 'foo' })
    @foo_doc3 = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc1 = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'stats' => { 'score' => 5 }, 'foo_id' => @foo_doc1['id'] })
    @fuu_doc2 = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'genghis', 'stats' => { 'score' => 8 }, 'foo_id' => @foo_doc2['id'] })

    class CopyName < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          add 'name', query('foobar/all_fuu').linked_by('foo_id').field('name')
          add 'victories', query('foobar/all_fuu').linked_by('foo_id').field('stats.score')
        end
      end
    end
    Migrator.run CopyName
  end

  it "should add name to all foos from their respective fuus" do
    @foobar.get(@foo_doc1['id'])['name'].should == 'attila'
    @foobar.get(@foo_doc2['id'])['name'].should == 'genghis'
  end

  it "should add victories referring nested field score" do
    @foobar.get(@foo_doc1['id'])['victories'].should == 5
    @foobar.get(@foo_doc2['id'])['victories'].should == 8
  end

  it "should not add name if doc does not have a linked fuu" do
    @foobar.get(@foo_doc3['id'])['name'].should == nil
    @foobar.get(@foo_doc3['id'])['victories'].should == nil
  end
end

describe 'copy field where the target field is linked by a field nested deep inside: ' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo' => { 'id' => @foo_doc['id'] }})

    class CopyName < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          add 'name', query('foobar/all_fuu').linked_by('foo.id').field('name')
        end
      end
    end
    Migrator.run CopyName
  end

  it "should retrieve and add name" do
    @foobar.get(@foo_doc['id'])['name'].should == 'attila'
  end
end

describe 'copy entire document into a field: ' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo_id' => @foo_doc['id'] })

    class CopyName < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          add 'fuu', query('foobar/all_fuu').linked_by('foo_id')
        end
      end
    end
    Migrator.run CopyName
  end

  it "should retrieve and add name" do
    @foobar.get(@foo_doc['id'])['fuu'].should == @foobar.get(@fuu_doc['id'])
  end
end

describe 'copy current document itself into a field (not real use case, keeping for syntax purposes): ' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo', 'name' => 'attila' })
    @expected_doc = @foobar.get(@foo_doc['id'])

    class CopyName < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          add 'fuu', doc
        end
      end
    end
    Migrator.run CopyName
  end

  it "should retrieve and add name" do
    @foobar.get(@foo_doc['id'])['fuu'].should == @expected_doc
  end
end
