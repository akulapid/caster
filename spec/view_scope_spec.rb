require 'spec_helper'

describe 'view scope: ' do
  before do
    @foo_type = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_type = @foobar.save_doc({ 'type' => 'fuu' })

    class AddNameToFoo < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          add 'name', 'atilla'
        end
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
