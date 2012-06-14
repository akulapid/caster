$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'rspec'
require 'migration'
require 'migrator'
require 'couchrest'

describe "Migration " do

  before do
    @foobar = CouchRest.database! 'http://127.0.0.1:5984/foobar'

    @foobar.save_doc({
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
    @foobar.delete!
  end

  describe 'add field: ' do
    before do
      @doc1 = @foobar.save_doc({})
      @doc2 = @foobar.save_doc({})
      @doc3 = @foobar.save_doc({})

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
        @foobar.get(doc['id'])['name'].should == 'atilla'
        @foobar.get(doc['id'])['occupation'].should == 'warrior'
      end
    end

    it "should add name field to design doc also" do
      @foobar.get('_design/foobar')['name'].should == 'atilla'
    end
  end

  describe 'view scope: ' do
    before do
      @foo_type = @foobar.save_doc({ 'type' => 'foo' })
      @fuu_type = @foobar.save_doc({ 'type' => 'fuu' })

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
      @foobar.get(@foo_type['id'])['name'].should == 'atilla'
    end

    it "should not add name field to view all_fuu" do
      @foobar.get(@fuu_type['id'])['name'].should == nil
    end
  end

  describe 'query scope: ' do
    before do
      @foo_loc1 = @foobar.save_doc({ 'loc' => 'foo' })
      @foo_loc2 = @foobar.save_doc({ 'loc' => 'foo' })
      @fuu_loc = @foobar.save_doc({ 'loc' => 'fuu' })

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
      @foobar.get(@foo_loc1['id'])['name'].should == 'atilla'
      @foobar.get(@foo_loc2['id'])['name'].should == 'atilla'
    end

    it "should not add name field to doc with loc != foo" do
      @foobar.get(@fuu_loc['id'])['name'].should == nil
    end
  end

  describe 'remove field: ' do
    before do
      @doc1 = @foobar.save_doc({ "type" => "foo", "name" => "carman", "state" => "on" })
      @doc2 = @foobar.save_doc({ "type" => "foo", "name" => "fifo" })
      @doc3 = @foobar.save_doc({ "type" => "foo" })

      class RemoveName < Migration
        on_database 'foobar'
        over_scope 'foobar/all_foo'

        up do
          remove 'name'
        end
      end

      Migrator.run RemoveName
    end

    it "should remove name field from all docs" do
      [@doc1, @doc2, @doc3].each do |doc|
        @foobar.get(doc['id'])['name'].should == nil
      end
    end
  end

end