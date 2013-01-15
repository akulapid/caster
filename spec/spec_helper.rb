$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'rspec'
require 'couchrest'
require 'caster'

RSpec.configure do |config|

  config.before :each do

    Caster.configure({
      'host' => '127.0.0.1',
      'port' => '5984'
    })

    @foobar = CouchRest.database! "http://#{Caster.config['host']}:#{Caster.config['port']}/foobar"

    @foobar.save_doc({
       '_id' => '_design/foobar',
       :views => {
           :all => {
               :map => "function(doc) { emit (doc._id, doc); }"
           },
           :all_foo => {
               :map => "function(doc) { if (doc.type == 'foo') emit (doc._id, doc); }"
           },
           :all_fuu => {
               :map => "function(doc) { if (doc.type == 'fuu') emit (doc._id, doc); }"
           },
           :all_fii => {
               :map => "function(doc) { if (doc.type == 'fii') emit (doc._id, doc); }"
           },
           :by_loc => {
               :map => "function(doc) { emit(doc.loc, doc); }"
           },
          :all_foo_ids => {
              :map => "function(doc) { if (doc.type == 'foo') emit (doc._id, doc._id); }"
          },
          :null_emitting_all_fuu => {
              :map => "function(doc) { if (doc.type == 'fuu') emit (null, doc._id); }"
          }
    }
    })
  end

  config.after :each do
    @foobar.delete!
  end
end