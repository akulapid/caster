require 'spec_helper'

describe 'config: ' do
  it "should use host and port values from config" do
    Caster.configure({ :host => 'host', :port => 'port' })

    CouchRest.should_receive('database').with('http://host:port/foobar')

    class Migration < Caster::Migration

      up do
        over_scope 'foobar/foobar/all' do
          add 'name', 'atilla'
        end
      end
    end
  end
end