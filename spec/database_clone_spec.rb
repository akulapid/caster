require 'spec_helper'

describe 'copy documents between databases: ' do
  before do
    @fuubar = CouchRest.database! 'http://127.0.0.1:5984/fuubar'
    @doc1 = @foobar.save_doc({ 'type' => 'foo' })

    class CloneDatabase < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          create_on('fuubar', doc)
        end
      end
    end
    Migrator.run CloneDatabase
  end

  it "should create @doc1 in fuubar" do
    @fuubar.get(@doc1['id'])['id'].should == @foobar.get(@doc1['id'])['id']
    @fuubar.get(@doc1['id'])['type'].should == @foobar.get(@doc1['id'])['type']
  end

  after do
    @fuubar.delete!
  end
end
