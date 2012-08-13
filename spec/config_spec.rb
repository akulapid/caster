require 'spec_helper'

describe 'config: ' do
  it "should use host and port values from config" do
    Caster.configure({ :host => 'host', :port => 'port' })

    CouchRest.should_receive('database').with('http://host:port/foobar')

    migrate 'foobar' do
    end
  end
end