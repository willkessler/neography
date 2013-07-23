require 'rspec'

# Load Deja lib
CURRENT_DIR = File.dirname(__FILE__)
$: << File.expand_path(CURRENT_DIR + '/../lib')
require 'factory_girl'
require 'deja'
include Deja

require File.dirname(__FILE__) + "/factories"

def generate_text(length=8)
  chars = 'abcdefghjkmnpqrstuvwxyz'
  key = ''
  length.times { |i| key << chars[rand(chars.length)] }
  key
end

# Start Neo4j server
Deja.neo = Neography::Rest.new()
