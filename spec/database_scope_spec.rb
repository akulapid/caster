require 'spec_helper'

describe 'using a database scope: ' do
  before do
    @doc = @foobar.save_doc({})
  end

  it "should add name and title to all docs in foo bar" do
    migrate 'foobar' do
      over 'foobar/all' do
        add 'name', 'atilla'
      end
      over 'foobar/all' do
        add 'title', 'warrior'
      end
    end

    @foobar.get(@doc['id'])['name'].should == 'atilla'
    @foobar.get(@doc['id'])['title'].should == 'warrior'
  end
end