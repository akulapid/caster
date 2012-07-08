require 'spec_helper'

describe 'query scope: ' do
  before do
    @foo_loc1 = @foobar.save_doc({ 'loc' => 'foo' })
    @foo_loc2 = @foobar.save_doc({ 'loc' => 'foo' })
    @fuu_loc = @foobar.save_doc({ 'loc' => 'fuu' })

    over 'foobar/foobar/by_loc', { 'key' => 'foo' } do
      add 'name', 'atilla'
    end
  end

  it "should add name field to all docs with loc = foo" do
    @foobar.get(@foo_loc1['id'])['name'].should == 'atilla'
    @foobar.get(@foo_loc2['id'])['name'].should == 'atilla'
  end

  it "should not add name field to doc with loc != foo" do
    @foobar.get(@fuu_loc['id'])['name'].should == nil
  end
end
