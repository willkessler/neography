require 'rspec'

# Load Deja lib
CURRENT_DIR = File.dirname(__FILE__)
$: << File.expand_path(CURRENT_DIR + '/../lib')
require 'factory_girl'
require 'deja'
include Deja

require File.dirname(__FILE__) + "/factories"

# Start Neo4j server
Deja.neo = Neography::Rest.new()
