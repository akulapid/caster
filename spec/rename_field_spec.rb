require 'spec_helper'

describe 'rename field: ' do
  before do
    @doc = @foobar.save_doc({ 'type' => 'foo', 'name' => 'carman' })

    over 'foobar/foobar/all_foo' do
      rename 'name', 'title'
    end
  end

  it 'should remove name field from all docs' do
    @foobar.get(@doc['id'])['name'].should == nil
    @foobar.get(@doc['id'])['title'].should == 'carman'
  end
end

describe 'rename nested field: ' do
  before do
    @doc = @foobar.save_doc({ 'type' => 'foo', 'profile' => { 'name' => 'carman', 'location' => 'unknown' }})

    over 'foobar/foobar/all_foo' do
      rename 'profile.name', 'profile.fullname'
    end
  end

  it 'should rename name under profile' do
    @foobar.get(@doc['id'])['profile']['fullname'].should == 'carman'
  end
end

describe 'move nested field to different hierarchy: ' do
  before do
    @doc = @foobar.save_doc({ 'type' => 'foo', 'account' => { 'name' => 'carman', 'location' => 'unknown' }, 'profile' => { 'age' => 0 }})

    over 'foobar/foobar/all_foo' do
      rename 'account.name', 'profile.name'
    end
  end

  it 'should move name from profile to account' do
    doc = @foobar.get(@doc['id'])
    doc['profile'].should == { 'name' => 'carman', 'age' => 0 }
    doc['account'].should == { 'location' => 'unknown' }
  end
end
