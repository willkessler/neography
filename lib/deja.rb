require 'neography'
require 'neo4j-cypher'
require 'neo4j-cypher/neography'

require 'active_model'
require 'active_support/core_ext'

require 'oj'
require 'yaml'

module Deja
  extend ActiveSupport::Autoload

  autoload :RestIndex
  autoload :Node
  autoload :Cast
  autoload :Query
  autoload :Batch
  autoload :Relationship
  autoload :SchemaGenerator
  autoload :RelNodeWrapper
  autoload :NeoParse
  autoload :Finders
  autoload :Error
  autoload :Bridge
  autoload :Model
  autoload :TypeCaster
  autoload :Parameterizer

  autoload_under 'types' do
    autoload :Boolean
  end

  Object.const_set(:Boolean, Deja::Boolean)

  extend Deja::RestIndex

  class << self; attr_accessor :neo, :batch ; end

  config_hash = YAML.load_file("#{File.dirname(File.expand_path(__FILE__))}/config/graph.yml")
  Neography.configure do |config|
    config_hash[ENV['RAILS_ENV'] || 'development'].each do |k, v|
      config.send("#{k}=".to_sym, v)
    end
  end
  Deja.neo = Neography::Rest.new()
  Deja.set_node_auto_index_status(true)
  Deja.set_relationship_auto_index_status(true)

  def self.cypher_read(query)
    parameterizing = true
    if parameterizing
      query, params = Deja::Parameterizer.parameterize_query(query)
      execute_cypher(query, params)
    else
      execute_cypher(query.to_s)
    end
  end

  def self.cypher_cud(query)
    parameterizing = true
    if parameterizing
      query, params = Deja::Parameterizer.parameterize_query(query)
      execute_cypher_batch(query, params)
    else
      execute_cypher_batch(query.to_s)
    end
  end

  def self.execute_cypher(query, params = nil)
    self.neo.execute_query(query, params)
  end

  def self.execute_cypher_batch(query, params = nil)
    if Deja.batch
      Deja.batch << [:execute_query, query, params]
    else
      execute_cypher(query, params)
    end
  end
end
