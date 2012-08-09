require 'spec_helper'

describe 'migrate caster script as string: ' do
  before do
    @doc = @foobar.save_doc({})
  end

  it "should add name all docs in foobar" do
    code =
      "over 'foobar/all' do
        add 'name', 'atilla'
      end"
    migrate_script 'foobar', code

    @foobar.get(@doc['id'])['name'].should == 'atilla'
  end
end