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

  s.required_ruby_version = '~> 2.4'

  s.add_dependency 'rails', '>= 5', '< 6'
  s.add_dependency 'timeliness', '~> 0.3.8'
  s.add_dependency 'unidecoder', '~> 1.1.0'
  s.add_dependency 'htmlentities', '~> 4.3.1'
  s.add_dependency 'qa', '~> 2.0'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'pry'
end
