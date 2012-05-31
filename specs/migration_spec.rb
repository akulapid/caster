$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'rspec'
require 'migration'
require 'migrator'
require 'couchrest'

describe "Migration " do

  before do
    @db = CouchRest.database! 'http://127.0.0.1:5984/foobar'

    @db.save_doc({
      '_id' => '_design/foobar',
      :views => {
        :all => {
          :map => "function(doc) { emit(doc._id, doc); }"
        },
        :all_foo => {
          :map => "function(doc) { if (doc.type == 'foo') emit (doc._id, doc); }"
        },
        :all_fuu => {
          :map => "function(doc) { if (doc.type == 'fuu') emit (doc._id, doc); }"
        }
      }
    })
  end

  after do
    @db.delete!
  end

  describe 'add field: ' do
    before do
      @doc1 = @db.save_doc({})
      @doc2 = @db.save_doc({})
      @doc3 = @db.save_doc({})

      class AddName < Migration
        on_database 'foobar'
        over_view 'foobar/all'

        up do
          add 'name', 'atilla'
        end
      end

      Migrator.run AddName
    end

    it "should add name field to all docs" do
      [@doc1, @doc2, @doc3].each do |doc|
        @db.get(doc['id'])['name'].should == 'atilla'
      end
    end
  end

  describe 'view scope: ' do
    before do
      @foo_type = @db.save_doc({ 'type' => 'foo' })
      @fuu_type = @db.save_doc({ 'type' => 'fuu' })

      class AddNameToFoo < Migration
        on_database 'foobar'
        over_view 'foobar/all_foo'

        up do
          add 'name', 'atilla'
        end
      end
      Migrator.run AddNameToFoo
    end

    it "should add name field to view all_foo" do
      @db.get(@foo_type['id'])['name'].should == 'atilla'
    end

    it "should not add name field to view all_fuu" do
      @db.get(@fuu_type['id'])['name'].should == nil
    end
  end
end