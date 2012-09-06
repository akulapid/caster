require 'spec_helper'

describe 'hash field access: ' do

  it 'should access field' do
    doc = { 'foo' => 'bar' }

    Accessor.new.get(doc, 'foo').should == 'bar'
  end

  it 'should access nested field' do
    doc = { 'foo' => { 'fuu' => 'baz' } }

    Accessor.new.get(doc, 'foo.fuu').should == 'baz'
  end

  it 'should set field' do
    doc = {}

    Accessor.new.set(doc, 'foo', 'bar')

    doc['foo'].should == 'bar'
  end

  it 'should set nested field' do
    doc = {}

    Accessor.new.set(doc, 'foo.fii.fuu', 'bar')

    doc['foo']['fii']['fuu'].should == 'bar'
  end

  it 'should preserve existing fields when setting nested field' do
    doc = { 'foo' => { 'fee' => {}, 'fii' => 'bir' }}

    Accessor.new.set(doc, 'foo.fee.fuu', 'bar')

    doc['foo']['fii'].should == 'bir'
  end

  it 'should delete field' do
    doc = { 'foo' => 'bar' }

    Accessor.new.delete doc, 'foo'

    doc.should == {}
  end

  it 'should delete nested field' do
    doc = { 'foo' => { 'fee' => { 'fii' => 'wii', 'fuu' => 'wuu' }}}

    Accessor.new.delete doc, 'foo.fee.fii'

    doc['foo']['fee'].should == { 'fuu' => 'wuu' }
  end

  it 'should escape dot as special character' do
    doc = { 'foo\.fuu' => 'bar' }

    Accessor.new.get(doc, 'foo\.fuu').should == 'bar'
  end
end
