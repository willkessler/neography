module Deja
  class Query
    include Deja::NeoParse

    class << self
      def create_node(attributes = {})
        cypher_query = Deja::Bridge.create_node(attributes)
        result_hash  = Deja.execute_cypher(cypher_query)
        node_id      = result_hash['data'].first.first
      end

      def delete_node(node_id)
        cypher_query = Deja::Bridge.delete_node(node_id)
        result_hash  = Deja.execute_cypher(cypher_query)
      end

      def update_node(node_id, attributes = {})
        cypher_query = Deja::Bridge.update_node(node_id, attributes)
        result_hash  = Deja.execute_cypher(cypher_query)
      end

      def create_relationship(start_node, end_node, name, direction = :none, attributes = {})
        cypher_query = Deja::Bridge.create_relationship(start_node, end_node, name, direction, attributes)
        result_hash  = Deja.execute_cypher(cypher_query)
        rel_id       = result_hash['data'].first.first
      end

      def delete_relationship(rel_id)
        cypher_query = Deja::Bridge.delete_relationship(rel_id)
        result_hash  = Deja.execute_cypher(cypher_query)
      end

      def load_entity(neo_id, options = {})
        load_entity_with_args(neo_id, options)
      end

      def load_entity_with_args(neo_id, options)
        options[:include] ||= :all
        cypher_query = Deja::Bridge.get_node_with_rels(neo_id, options[:include])
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash)
      end

      def load_related_nodes(neo_id, options = {})
        load_related_nodes_with_args(neo_id, options)
      end

      def load_related_nodes_with_args(neo_id, options)
        options[:include] ||= :all
        cypher_query = Deja::Bridge.get_related_nodes(neo_id, options[:include])
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash, :lazy)
      end
    end
  end
end
