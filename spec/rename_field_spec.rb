require 'spec_helper'

describe 'rename field: ' do
  before do
    @doc = @foobar.save_doc({ "type" => "foo", "name" => "carman" })

    class RenameName < Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          rename 'name', 'title'
        end
      end
    end
    Migrator.run RenameName
  end

  it "should remove name field from all docs" do
    @foobar.get(@doc['id'])['name'].should == nil
    @foobar.get(@doc['id'])['title'].should == 'carman'
  end
end
