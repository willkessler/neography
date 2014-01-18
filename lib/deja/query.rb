module Deja
  class Query
    include Deja::NeoParse

    class << self
      def load_node(neo_id, options = {})
        options[:return_root] = options[:include] ? :root_rel_end : :root_only
        options[:include] ||= :none
        cypher_query = Deja::Bridge.get_nodes(neo_id, options)
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash)
      end

      def load_related_nodes(neo_id, options = {})
        options[:return_root] ||= :rel_end
        cypher_query = Deja::Bridge.get_nodes(neo_id, options)
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash, :lazy)
      end

      def create_node(attributes = {})
        # skip nil/empty attributes
        attributes.select!{ |attribute, value| value.present? }

        begin
          cypher_query = Deja::Bridge.create_node(attributes)
          result_hash  = Deja.execute_cypher(cypher_query)
          node_id      = result_hash['data'].first.first
        rescue
          nil
        end
      end

      def delete_node(node_id)
        cypher_query = Deja::Bridge.delete_node(node_id)
        result_hash  = Deja.execute_cypher(cypher_query)
      end

      def update_node(node_id, attributes = {})
        cypher_query = Deja::Bridge.update_node(node_id, attributes)
        result_hash  = Deja.execute_cypher(cypher_query)
        normalize(result_hash)
      end

      def count_nodes(index)
        cypher_query = Deja::Bridge.count_nodes(index)
        result_hash  = Deja.execute_cypher(cypher_query)
        rel_count    = result_hash['data'].first.first
      end

      def count_relationships(id, type, direction)
        cypher_query = Deja::Bridge.count_rels(id, type, direction)
        result_hash  = Deja.execute_cypher(cypher_query)
        rel_count    = result_hash['data'].first.first
      end

      def count_connections(id)
        cypher_query = Deja::Bridge.count_connections(id)
        result_hash  = Deja.execute_cypher(cypher_query)
        rel_count    = result_hash['data'].first.first
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

      def create_relationship(start_node, end_node, label, attributes = {})
        # skip nil/empty attributes
        attributes.select!{ |attribute, value| value.present? }

        begin
          cypher_query = Deja::Bridge.create_relationship(start_node, end_node, label, attributes)
          result_hash  = Deja.execute_cypher(cypher_query)
          rel_id       = result_hash['data'].first.first
        rescue
          nil
        end
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
    end
  end
end
