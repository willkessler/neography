require 'neography'
require 'neo4j-cypher'
require 'neo4j-cypher/neography'

require 'active_model'
require 'active_support'

require 'oj'

#require 'lib/metaid'

module Deja
  extend ActiveSupport::Autoload
  autoload :Index
  autoload :Node
  autoload :Relationship
  autoload :SchemaGenerator
  autoload :RelNodeWrapper
  autoload :Finders
  autoload :Error
  autoload :Bridge

  class << self; attr_accessor :neo; end

  def self.execute_cypher(query)
    self.neo.execute_query(query.to_s)
  end

end
