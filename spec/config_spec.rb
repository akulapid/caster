require 'spec_helper'

describe 'config: ' do
  it "should use host and port values from config" do
    Caster.configure({ :host => 'host', :port => 'port' })

    CouchRest.should_receive('database').with('http://host:port/foobar')

    class Migration < Caster::Migration
      on_database 'foobar'
    end
  end
end