require 'spec_helper'
require 'migration'
require 'migrator'
require 'couchrest'

describe 'add field: ' do
  before do
    @doc1 = @foobar.save_doc({})
    @doc2 = @foobar.save_doc({})
    @doc3 = @foobar.save_doc({})

    class AddNameAndOccupation < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all' do
          add 'name', 'atilla'
          add 'occupation', 'warrior'
        end
      end
    end
    Migrator.run AddNameAndOccupation
  end

  it "should add name and occupation fields to all created docs" do
    [@doc1, @doc2, @doc3].each do |doc|
      @foobar.get(doc['id'])['name'].should == 'atilla'
      @foobar.get(doc['id'])['occupation'].should == 'warrior'
    end
  end
end