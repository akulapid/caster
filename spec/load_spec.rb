require 'spec_helper'

describe 'migrating large number of documents' do

  it "should add name" do
    total_docs = 10#0000
    Caster.config['batch_size'] = 10000

    (0..total_docs - 1).each do |i|
      @foobar.save_doc({
        '_id' => i.to_s,
        'type' => 'foo',
        'o' => 'conscience,',
        'upright' => 'and',
        'stainless' => {
            'how' => 'bitter',
            'a' => 'sting',
        },
        'to' => 'thee',
        'is' => 'a',
        'little' => 'fault!'
      }, true)
    end
    @foobar.save_doc({})   # force bulk save
    @foobar.view('foobar/all_foo')  # warm index
    p "saved #{total_docs} docs. starting load test.."

    start = Time.now
    over 'foobar/foobar/all_foo' do
      add 'name', 'atilla'
    end
    p "migrated in #{Time.now - start} seconds."

    p "verifying migration.."
    @foobar.view('foobar/all_foo')['rows'].each do |doc|
      doc['value']['name'].should == 'atilla'
    end
    p "load test complete."
  end
end
