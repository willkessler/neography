require 'neography'
require 'neo4j-cypher'
require 'neo4j-cypher/neography'

require 'active_model'
require 'active_support'

module Deja
  extend ActiveSupport::Autoload
  autoload :Node
  autoload :Error
  @neo = Neography::Rest.new
end
