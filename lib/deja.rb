require 'neography'
require 'neo4j-cypher'
require 'neo4j-cypher/neography'

require 'active_model'
require 'active_support/core_ext'

require 'oj'
require 'yaml'

module Deja
  extend ActiveSupport::Autoload

  ENV['RAILS_ENV'] ||= 'development'

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
  autoload :TypeCaster

  autoload_under 'types' do
    autoload :Boolean
  end

  Object.const_set(:Boolean, Deja::Boolean)

  extend Deja::RestIndex

  class << self; attr_accessor :neo, :tx, :batch ; end

  config_hash = YAML.load_file("#{File.dirname(File.expand_path(__FILE__))}/config/graph.yml")
  Neography.configure do |config|
    config_hash[ENV['RAILS_ENV']].each do |k, v|
      config.send("#{k}=".to_sym, v)
    end
  end
  Deja.neo = Neography::Rest.new()
  Deja.set_node_auto_index_status(true)
  Deja.set_relationship_auto_index_status(true)

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
