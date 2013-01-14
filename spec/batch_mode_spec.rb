require 'spec_helper'

describe 'executing in batch mode: ' do

  it "should add name with various batch sizes" do
    [0, 1, 3, 6, 7].each do |total_docs|
      (0..total_docs - 1).each do |i|
        @foobar.save_doc({ 'type' => 'foo', '_id' => i.to_s })
      end

      Caster.config[:batch_size] = 3

      over 'foobar/foobar/all_foo' do
        add 'name', 'atilla'
      end

      (0..total_docs - 1).each do |i|
        @foobar.get(i.to_s)['name'].should == 'atilla'
        @foobar.get(i.to_s).id.should == i.to_s
        @foobar.delete_doc @foobar.get(i.to_s)
      end
    end
  end

  it "should honor user specified limit param in batch mode" do
    [0, 1, 3, 6, 7].each do |limit|
      (0..9).each do |i|
        @foobar.save_doc({ 'type' => 'foo', '_id' => i.to_s })
      end

      Caster.config[:batch_size] = 3

      over 'foobar/foobar/all_foo', { 'limit' => limit } do
        add 'name', 'atilla'
      end

      (0..limit - 1).each do |i|
        @foobar.get(i.to_s)['name'].should == 'atilla'
        @foobar.delete_doc @foobar.get(i.to_s)
      end
      (limit..9).each do |i|
        @foobar.get(i.to_s)['name'].should == nil
        @foobar.delete_doc @foobar.get(i.to_s)
      end
    end
  end

  it "should honor user specified startkey and endkey in batch mode" do
      (0..9).each do |i|
        @foobar.save_doc({ 'type' => 'foo', '_id' => i.to_s })
      end

      Caster.config[:batch_size] = 2

      over 'foobar/foobar/all_foo', { 'startkey' => '4', 'endkey' => '7' } do
        add 'name', 'atilla'
      end

      (0..3).each do |i|
        @foobar.get(i.to_s)['name'].should == nil
      end
      (4..7).each do |i|
        @foobar.get(i.to_s)['name'].should == 'atilla'
      end
      (8..9).each do |i|
        @foobar.get(i.to_s)['name'].should == nil
      end
  end
end

describe 'refer documents from another database' do
  before do
    @fuubar = CouchRest.database! 'http://127.0.0.1:5984/fuubar'
    @fuubar.save_doc({
         '_id' => '_design/fuubar',
         :views => {
             :all_fuu => {
                 :map => "function(doc) { if (doc.type == 'fuu') emit (doc._id, doc); }"
             }
         }
    })
  end

  Caster.config[:batch_size] = 4

  it "should refer and add name" do
    total_docs = 10
    (0..total_docs - 1).each do |i|
      @foobar.save_doc({ 'type' => 'foo', '_id' => i.to_s })
      @fuubar.save_doc({ 'type' => 'fuu', 'foo_id' => i.to_s, 'name' => "atilla" })
    end

    over 'foobar/foobar/all_foo' do |doc|
      add 'name', from('fuubar/fuubar/all_fuu').where{ |src| src['foo_id'] == doc['_id'] }['name']
    end

    (0..total_docs - 1).each do |i|
      @foobar.get(i.to_s)['name'].should == "atilla"
    end
  end

  after do
    @fuubar.delete!
  end
end
