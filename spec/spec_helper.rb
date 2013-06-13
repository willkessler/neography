require 'rspec'

# Load Deja lib
CURRENT_DIR = File.dirname(__FILE__)
$: << File.expand_path(CURRENT_DIR + '/../lib')
#require File.dirname(__FILE__) + "/factories"
require 'deja'
include Deja

# Start Neo4j server
begin
  Deja.neo = Neography::Rest.new()
rescue Errno::ECONNREFUSED => e
  cmd = ''
  cmd << 'rake neo4j:install;' unless File.exists?('neo4j')
  cmd << 'rake neo4j:start; echo Neo4j has started. Please re-run rspec. Note: to stop neo4j, run \"rake neo4j:stop\"'
  exec(cmd)
rescue Neography::NeographyError
  Deja.neo = Neography::Rest.new()
end
