module Deja
  class Query
    include Deja::NeoParse

    class << self
      def load_node(neo_id, options = {})
        load_node_with_args(neo_id, options)
      end

      def load_related_nodes(neo_id, options = {})
        r = load_related_nodes_with_args(neo_id, options)
        r
      end

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
        result_hash["data"].empty? ? false : true
      end

      def count_relationships(id, type = :all)
        if type
          cypher_query = Deja::Bridge.count_relationships(id, type)
        else
          cypher_query = Deja::Bridge.count_relationships(id)
        end
        result_hash = Deja.execute_cypher(cypher_query)
      end

      def load_relationship(id_or_index)
        cypher_query = Deja::Bridge.get_relationship(id_or_index)
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash)
      end

      def load_relationship_from_nodes(start_node, end_node, type)
        cypher_query = Deja::Bridge.get_relationship_from_nodes(start_node, end_node, type)
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash)
      end

      def load_relationship_from_node_indexes(start_node, end_node, type)
        cypher_query = Deja::Bridge.get_relationship_from_node_indexes(start_node, end_node, type)
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash)
      end

      def create_relationship(start_node, end_node, label, attributes = {})
        cypher_query = Deja::Bridge.create_relationship(start_node, end_node, label, attributes)
        result_hash  = Deja.execute_cypher(cypher_query)
        rel_id       = result_hash['data'].first.first
      end

      def create_relationship_from_index(start_node, end_node, label, attributes = {})
        cypher_query = Deja::Bridge.create_relationship_from_index(start_node, end_node, label, attributes)
        result_hash  = Deja.execute_cypher(cypher_query)
        rel_id       = result_hash['data'].first.first
      end

      def delete_relationship(rel_id)
        cypher_query = Deja::Bridge.delete_relationship(rel_id)
        result_hash  = Deja.execute_cypher(cypher_query)
      end

      def update_relationship(rel_id, attributes = {})
        cypher_query = Deja::Bridge.update_relationship(rel_id, attributes)
        result_hash  = Deja.execute_cypher(cypher_query)
        result_hash["data"].empty? ? false : true
      end

      def load_node_with_args(neo_id, options)
        cypher_query = Deja::Bridge.get_node_with_rels(neo_id, options)
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash)
      end

      def load_related_nodes_with_args(neo_id, options)
        cypher_query = Deja::Bridge.get_related_nodes(neo_id, options)
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash, :lazy)
      end
    end
  end
end
