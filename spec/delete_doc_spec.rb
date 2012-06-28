require 'spec_helper'

describe 'delete doc: ' do
  before do
    @doc1 = @foobar.save_doc({ 'type' => 'foo', 'name' => 'attila' })
    @doc2 = @foobar.save_doc({ 'type' => 'foo', 'name' => 'genghis' })

    class DeleteDoc < Caster::Migration
      on_database 'foobar'

      up do
        over_scope 'foobar/all_foo' do
          delete
        end
      end
    end
    Caster::Migrator.run DeleteDoc
  end

  it "should create a fuu for each foo" do
    @foobar.view('foobar/all_foo')['rows'].should == []
  end
end