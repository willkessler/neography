require 'neography'
require 'neo4j-cypher'
require 'neo4j-cypher/neography'

require 'active_model'
require 'active_support'

require 'oj'

module Deja
  extend ActiveSupport::Autoload
  autoload :Index
  autoload :Node
  autoload :Cast
  autoload :Query
  autoload :Transaction
  autoload :Relationship
  autoload :SchemaGenerator
  autoload :RelNodeWrapper
  autoload :NeoParse
  autoload :Finders
  autoload :Error
  autoload :Bridge

  ID            = 'id'
  REL           = 'rel'
  NODE          = 'node'
  TYPE          = 'type'
  START_NODE    = 'start_node'
  END_NODE      = 'end_node'
  RELATIONSHIPS = 'relationships'

  class << self; attr_accessor :neo, :tx ; end

  def self.execute_cypher(query)
    if (Deja.tx)
      Deja.neo.in_transaction(Deja.tx, query.to_s)
    else
      self.neo.execute_query(query.to_s)
    end
  end
end
