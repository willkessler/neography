require 'rspec'

# Load Deja lib
CURRENT_DIR = File.dirname(__FILE__)
$: << File.expand_path(CURRENT_DIR + '/../lib')
require 'deja'
include Deja

# Start Neo4j server
begin
  @neo = Neography::Rest.new(:directory => '/deja-test')
rescue Neography::NeographyError
  exec('rake neo4j:start') # if @neo.get_root[:reference_node]
  # Sets the test Neography connection
  @neo = Neography::Rest.new(:directory => '/deja-test')
end