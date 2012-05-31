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
        #:all => {
        #  :map => "function(doc) { emit(doc._id, doc); }"
        #},
        :all_foo => {
          :map => "function(doc) { if (doc.type == 'foo') emit (doc._id, doc); }"
        },
        :all_fuu => {
          :map => "function(doc) { if (doc.type == 'fuu') emit (doc._id, doc); }"
        },
        :by_loc => {
          :map => "function(doc) { emit(doc.loc, doc); }"
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

        up do
          add 'name', 'atilla'
          add 'occupation', 'warrior'
        end
      end

      Migrator.run AddName
    end

    it "should add name field to all created docs" do
      [@doc1, @doc2, @doc3].each do |doc|
        @db.get(doc['id'])['name'].should == 'atilla'
        @db.get(doc['id'])['occupation'].should == 'warrior'
      end
    end

    it "should add name field to design doc also" do
      @db.get('_design/foobar')['name'].should == 'atilla'
    end
  end

  describe 'view scope: ' do
    before do
      @foo_type = @db.save_doc({ 'type' => 'foo' })
      @fuu_type = @db.save_doc({ 'type' => 'fuu' })

      class AddNameToFoo < Migration
        on_database 'foobar'
        over_scope 'foobar/all_foo'

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

  describe 'query scope: ' do
    before do
      @foo_loc1 = @db.save_doc({ 'loc' => 'foo' })
      @foo_loc2 = @db.save_doc({ 'loc' => 'foo' })
      @fuu_loc = @db.save_doc({ 'loc' => 'fuu' })

      class AddNameToFoo < Migration
        on_database 'foobar'
        over_scope 'foobar/by_loc', { 'key' => 'foo' }

        up do
          add 'name', 'atilla'
        end
      end
      Migrator.run AddNameToFoo
    end

    it "should add name field to all docs with loc = foo" do
      @db.get(@foo_loc1['id'])['name'].should == 'atilla'
      @db.get(@foo_loc2['id'])['name'].should == 'atilla'
    end

    it "should not add name field to doc with loc != foo" do
      @db.get(@fuu_loc['id'])['name'].should == nil
    end
  end
end