require 'neography'
require 'neo4j-cypher'
require 'neo4j-cypher/neography'

require 'active_model'
require 'active_support'

require 'oj'

module Deja
  extend ActiveSupport::Autoload

  autoload :RestIndex
  autoload :Node
  autoload :Cast
  autoload :Query
  autoload :Batch
  autoload :Transaction
  autoload :Relationship
  autoload :SchemaGenerator
  autoload :RelNodeWrapper
  autoload :NeoParse
  autoload :Finders
  autoload :Error
  autoload :Bridge
  autoload :Model

  extend Deja::RestIndex

  INDEX_DELIM   = '^^^'

  class << self; attr_accessor :neo, :tx, :batch ; end

  def self.execute_cypher(query)
    if Deja.tx
      Deja.neo.in_transaction(Deja.tx, query.to_s)
    elsif Deja.batch
      Deja.batch << [:execute_query, query.to_s]
    else
      self.neo.execute_query(query.to_s)
    end
  end

  def self.execute_gremlin(query)
    self.neo.execute_script(query)
  end
end
