require 'spec_helper'

describe 'refer field from another doc type: ' do
  before do
    @foo_doc1 = @foobar.save_doc({ 'type' => 'foo' })
    @foo_doc2 = @foobar.save_doc({ 'type' => 'foo' })
    @foo_doc3 = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc1 = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'stats' => { 'score' => 5 }, 'foo_id' => @foo_doc1['id'] })
    @fuu_doc2 = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'genghis', 'stats' => { 'score' => 8 }, 'foo_id' => @foo_doc2['id'] })

    over 'foobar/foobar/all_foo' do |doc|
      add 'name', from('foobar/all_fuu').where{ |src| src['foo_id'] == doc['_id'] }['name']
      add 'victories', from('foobar/all_fuu').where{ |src| src['foo_id'] == doc['_id'] }['stats']['score']
    end
  end

  it "should add name to all foos from their respective fuus" do
    @foobar.get(@foo_doc1['id'])['name'].should == 'attila'
    @foobar.get(@foo_doc2['id'])['name'].should == 'genghis'
  end

  it "should add victories referring nested field score" do
    @foobar.get(@foo_doc1['id'])['victories'].should == 5
    @foobar.get(@foo_doc2['id'])['victories'].should == 8
  end

  it "should not add name if doc does not have a linked fuu" do
    @foobar.get(@foo_doc3['id'])['name'].should == nil
    @foobar.get(@foo_doc3['id'])['victories'].should == nil
  end
end

describe 'refer fields from multiple doc types: ' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo_id' => @foo_doc['id'] })
    @fii_doc = @foobar.save_doc({ 'type' => 'fii', 'title' => 'warrior', 'foo_id' => @foo_doc['id'] })

    over 'foobar/foobar/all_foo' do |doc|
      add 'name', from('foobar/all_fuu').where{ |src| src['foo_id'] == doc['_id'] }['name']
      add 'title', from('foobar/all_fii').where{ |src| src['foo_id'] == doc['_id'] }['title']
    end
  end

  it "should add name and title to foo from the respective fuu and fii" do
    @foobar.get(@foo_doc['id'])['name'].should == 'attila'
    @foobar.get(@foo_doc['id'])['title'].should == 'warrior'
  end
end

describe 'copy field where the target field is linked by a field nested deep inside: ' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo' => { 'id' => @foo_doc['id'] }})

    over 'foobar/foobar/all_foo' do |doc|
      add 'name', from('foobar/all_fuu').where{ |src| src['foo']['id'] == doc['_id'] }['name']
    end
  end

  it "should retrieve and add name" do
    @foobar.get(@foo_doc['id'])['name'].should == 'attila'
  end
end

describe 'copy entire document into a field: ' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo_id' => @foo_doc['id'] })

    over 'foobar/foobar/all_foo' do |doc|
      add 'fuu', from('foobar/all_fuu').where{ |src| src['foo_id'] == doc['_id'] }
    end
  end

  it "should retrieve and add name" do
    @foobar.get(@foo_doc['id'])['fuu'].should == @foobar.get(@fuu_doc['id'])
  end
end

describe 'operations over self reference' do
  before do
    @doc = @foobar.save_doc({ 'type' => 'foo', 'name' => 'attila' })

    over 'foobar/foobar/all_foo' do |doc|
      add 'foo', doc['name'].upcase
      add 'fuu', doc['name'].upcase.sub('ATTI', 'HO')
    end
  end

  it "should add uppercase name" do
    @foobar.get(@doc['id'])['foo'].should == 'ATTILA'
  end

  it "should add transformed uppercase name" do
    @foobar.get(@doc['id'])['fuu'].should == 'HOLA'
  end
end

describe 'method call over reference: ' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo_id' => @foo_doc['id'] })

    over 'foobar/foobar/all_foo' do |doc|
      add 'name', from('foobar/all_fuu').where{ |src| src['foo_id'] == doc['_id'] }['name'].upcase!
    end
  end

  it "should retrieve and add upper case name" do
    @foobar.get(@foo_doc['id'])['name'].should == 'ATTILA'
  end
end

describe 'array operation over reference' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'names' => ['attila', 'the hun'], 'foo_id' => @foo_doc['id'] })

    over 'foobar/foobar/all_foo' do |doc|
      add 'name', from('foobar/all_fuu').where{ |src| src['foo_id'] == doc['_id'] }['names'][1]
    end
  end

  it "should retrieve and add last name" do
    @foobar.get(@foo_doc['id'])['name'].should == 'the hun'
  end
end

describe 'object instance method calls on reference' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo', 'name' => 'attila' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo_id' => @foo_doc['id'] })

    over 'foobar/foobar/all_foo' do |doc|
      add 'class', from('foobar/all_fuu').where{ |src| src['foo_id'] == doc['_id'] }['name'].class
    end
  end

  it "should call method on target and not references" do
      @foobar.get(@foo_doc['id'])['class'].should == 'String'
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

    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @fuubar.save_doc({ 'type' => 'fuu', 'foo_id' => @foo_doc['id'], 'name' => 'atilla' })

    over 'foobar/foobar/all_foo' do |doc|
      add 'name', from('fuubar/fuubar/all_fuu').where{ |src| src['foo_id'] == doc['_id'] }['name']
    end
  end

  it "should refer and add name" do
    @foobar.get(@foo_doc['id'])['name'].should == 'atilla'
  end

  after do
    @fuubar.delete!
  end
end

describe 'field reference over view that emits null' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo_id' => @foo_doc['id'] })

    over 'foobar/foobar/all_foo' do |foo|
      add 'name', from('foobar/null_emitting_all_fuu', 'include_docs' => 'true').where{ |fuu| fuu['foo_id'] == foo['_id'] }['name']
    end
  end

  it 'should add name to all foos from their respective fuus' do
    @foobar.get(@foo_doc['id'])['name'].should == 'attila'
  end
end
