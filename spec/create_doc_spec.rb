require 'spec_helper'

describe 'create doc: ' do
  before do
    @doc1 = @foobar.save_doc({ 'type' => 'foo', 'name' => 'attila' })
    @doc2 = @foobar.save_doc({ 'type' => 'foo', 'name' => 'genghis' })

    over 'foobar/foobar/all_foo' do
      create({ 'type' => 'fuu', 'title' => doc('name') })
    end
  end

  it "should create a fuu for each foo" do
    @foobar.view('foobar/all_fuu')['rows'].map { |rdoc| rdoc['value']['title'] }.should == ['attila', 'genghis']
  end
end