require 'neography'
require 'neo4j-cypher'
require 'neo4j-cypher/neography'

require 'active_model'
require 'active_support'

require 'oj'

module Deja
  extend ActiveSupport::Autoload
  autoload :Node
  autoload :Finders
  autoload :Error
  autoload :Bridge
end
