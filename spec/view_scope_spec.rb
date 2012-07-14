require 'spec_helper'

describe 'view scope: ' do
  before do
    @foo_type = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_type = @foobar.save_doc({ 'type' => 'fuu' })
    @fii_type = @foobar.save_doc({ 'type' => 'fii' })

    over 'foobar/foobar/all_foo' do
      add 'name', 'atilla'
    end

    over 'foobar/foobar/all_fii' do
      add 'name', 'genghis'
    end
  end

  it "should add name field to view all_foo" do
    @foobar.get(@foo_type['id'])['name'].should == 'atilla'
  end

  it "should not add name field to view all_fuu" do
    @foobar.get(@fuu_type['id'])['name'].should == nil
  end

  it "should add name field to view all_fii" do
    @foobar.get(@fii_type['id'])['name'].should == 'genghis'
  end
end

describe 'view with include docs' do
  before do
    @doc1 = @foobar.save_doc({ 'type' => 'foo' })
    @doc2 = @foobar.save_doc({ 'type' => 'foo' })

    over 'foobar/foobar/all_foo_ids', 'include_docs' => 'true' do
      add 'name', 'atilla'
    end
  end

  it "should add name field to view that emits doc ids" do
    @foobar.get(@doc1['id'])['name'].should == 'atilla'
    @foobar.get(@doc2['id'])['name'].should == 'atilla'
  end
end

describe 'query scope' do
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

describe 'refer scoped documents' do
  before do
    @doc = @foobar.save_doc({ 'type' => 'foo', 'name' => 'attila', 'stats' => { 'score' => 5 }})

    over 'foobar/foobar/all_foo' do |doc|
      add 'title', doc['name']
      add 'victories', doc['stats']['score']
    end
  end

  it "should refer and add name" do
    @foobar.get(@doc['id'])['name'].should == 'attila'
  end

  it "should refer and add nested field score" do
    @foobar.get(@doc['id'])['victories'].should == 5
  end
end
