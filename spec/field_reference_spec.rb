require 'spec_helper'

describe 'refer field within the same document: ' do
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

describe 'refer field from another doc type: ' do
  before do
    @foo_doc1 = @foobar.save_doc({ 'type' => 'foo' })
    @foo_doc2 = @foobar.save_doc({ 'type' => 'foo' })
    @foo_doc3 = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc1 = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'stats' => { 'score' => 5 }, 'foo_id' => @foo_doc1['id'] })
    @fuu_doc2 = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'genghis', 'stats' => { 'score' => 8 }, 'foo_id' => @foo_doc2['id'] })

    over 'foobar/foobar/all_foo' do
      add 'name', from('foobar/all_fuu#name').linked_by('foo_id')
      add 'victories', from('foobar/all_fuu#stats.score').linked_by('foo_id')
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

describe 'copy field where the target field is linked by a field nested deep inside: ' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @foobar.save_doc({ 'type' => 'fuu', 'name' => 'attila', 'foo' => { 'id' => @foo_doc['id'] }})

    over 'foobar/foobar/all_foo' do
      add 'name', from('foobar/all_fuu#name').linked_by('foo.id')
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

    over 'foobar/foobar/all_foo' do
      add 'fuu', from('foobar/all_fuu').linked_by('foo_id')
    end
  end

  it "should retrieve and add name" do
    @foobar.get(@foo_doc['id'])['fuu'].should == @foobar.get(@fuu_doc['id'])
  end
end

describe 'copy current document itself into a field (not real use case, keeping for syntax purposes): ' do
  before do
    @foo_doc = @foobar.save_doc({ 'type' => 'foo', 'name' => 'attila' })
    @expected_doc = @foobar.get(@foo_doc['id'])

    over 'foobar/foobar/all_foo' do |doc|
      add 'fuu', doc
    end
  end

  it "should retrieve and add name" do
    @foobar.get(@foo_doc['id'])['fuu'].should == @expected_doc
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

    over 'foobar/foobar/all_foo' do
      add 'name', from('foobar/all_fuu#name').linked_by('foo_id').upcase!
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

    over 'foobar/foobar/all_foo' do
      add 'name', from('foobar/all_fuu#names').linked_by('foo_id')[1]
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

    over 'foobar/foobar/all_foo' do
      add 'class', from('foobar/all_fuu#name').linked_by('foo_id').class
    end
  end

  it "should call method on target and not references" do
      @foobar.get(@foo_doc['id'])['class'].should == 'String'
  end
end
