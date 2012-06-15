$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'rspec'
require 'migration'
require 'migrator'
require 'couchrest'

RSpec.configure do |config|

  config.before :each do
    @foobar = CouchRest.database! 'http://127.0.0.1:5984/foobar'

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
           :by_loc => {
               :map => "function(doc) { emit(doc.loc, doc); }"
           }
       }
    })
  end

  config.after :each do
    @foobar.delete!
  end
end