require 'spec_helper'

describe 'update field: ' do
  before do
    @doc1 = @foobar.save_doc({ 'type' => 'foo', 'score' => '43' })
    @doc2 = @foobar.save_doc({ 'type' => 'foo', 'score' => '13' })

    class UpdateScore < Caster::Migration

      up do
        over_scope 'foobar/foobar/all_foo' do
          update 'score', '0'
        end
      end
    end
    Caster::Migrator.run UpdateScore
  end

  it "should reset score of all foos" do
    [@doc1, @doc2].each do |doc|
      @foobar.get(doc['id'])['score'].should == '0'
    end
  end
end