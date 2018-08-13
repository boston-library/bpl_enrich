$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bpl_enrich/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bpl_enrich"
  s.version     = BplEnrich::VERSION
  s.authors     = ["Boston Public Library"]
  s.email       = ["sanderson@bpl.org", "eenglish@bpl.org"]
  s.homepage    = "http://www.bpl.org"
  s.summary     = "Methods for enriching and standardizing metadata."
  s.description = "Methods for enriching and standardizing metadata."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4"
  s.add_dependency "timeliness"
  s.add_dependency 'unidecoder'
  s.add_dependency 'htmlentities'
  s.add_dependency 'qa', '~> 1.0'
  s.add_development_dependency "sqlite3"
end
