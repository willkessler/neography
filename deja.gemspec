# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'deja/version'

Gem::Specification.new do |s|
  s.name        = "deja"
  s.version     = Deja::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Kamran Pakseresht"
  s.email       = "kamran@crunchbase.com"
  s.summary     = "Creates a light ORM that implements basic CRUD operations for Neo4J using an ActiveRecord style interface."
  s.description = ""

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~>2.13.0"
  s.add_development_dependency "factory_girl"
  s.add_dependency "neography"
  s.add_dependency "neo4j-cypher"
  s.add_dependency "activemodel"
  s.add_dependency "activesupport"
  s.add_dependency "oj"
end
