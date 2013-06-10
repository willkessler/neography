require 'neography'
require 'neo4j-cypher'
require 'neo4j-cypher/neography'

require 'active_model'
require 'active_support'

require 'oj'

module Deja
  extend ActiveSupport::Autoload
  autoload :Metaid
  autoload :Node
  autoload :Relationship
  autoload :SchemaGenerator
  autoload :Finders
  autoload :Error
  autoload :Bridge

  class << self; attr_accessor :neo; end

  def self.execute_cypher(query)
    self.neo.execute_query(query.to_s)
  end

end
