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