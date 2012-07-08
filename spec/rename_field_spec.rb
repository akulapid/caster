require 'spec_helper'

describe 'rename field: ' do
  before do
    @doc = @foobar.save_doc({ "type" => "foo", "name" => "carman" })

    over 'foobar/foobar/all_foo' do
      rename 'name', 'title'
    end
  end

  it "should remove name field from all docs" do
    @foobar.get(@doc['id'])['name'].should == nil
    @foobar.get(@doc['id'])['title'].should == 'carman'
  end
end
