Gem::Specification.new do |s|
  s.name        = 'caster'
  s.version     = '0.9.0'
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Casters for your couch database"
  s.description = "A migration framework for couchdb databases"
  s.authors     = ["Manohar Akula"]
  s.email       = 'manohar.akula@gmail.com'
  s.homepage    = 'http://github.com/akula1001/caster'
  s.files       = `git ls-files lib`.split("\n")
  s.executables << 'cast'
end