require 'spec_helper'

describe 'couchrest operations: ' do

  it "should save doc using couchrest save_doc()" do
    migrate 'foobar' do
      save_doc({ '_id' => 'abc', 'type' => 'foo' })
    end

    @foobar.get('abc')['type'].should == 'foo'
  end

  it "should not call non-couchrest functions" do
    migrate 'foobar' do
      lambda { save_yourself }.should raise_exception
    end
  end
end