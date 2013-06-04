module Deja
  #
  # low-level cypher executions, most db access runs through bridge
  #
  module Bridge
    extend ActiveSupport::Concern

    module ClassMethods

      def is_index?(node_lookup)
        node_lookup.is_a?(Hash)
      end

      def sane_hash(hash)
        clean_hash = []
        hash['data'].first.each do |record|
          attr_hash = {}
          attr_hash[:id] = record['self'].split('/').last.to_i
          attr_hash[:type] = record['type'] if record['type']
          record['data'].each do |key, value|
            attr_hash[key.to_sym] = value
          end
          clean_hash << attr_hash
        end
        clean_hash
      end

      def create_node(attributes = {})
        raise Deja::Error::InvalidParameter unless attributes
        raise Deja::Error::NoParameter if attributes.empty?
        create_query = Neo4j::Cypher.query() do
          node.new(attributes).neo_id
        end
        Deja.neo.execute_query(create_query)['data'].first.first
      end

      def update_node(node, attributes)
        is_index?(node) ? update_node_by_index(node, attributes) : update_node_by_id(node, attributes)
      end

      def update_node_by_id(node_id, attributes)
        update_query = Neo4j::Cypher.query do
          node(node_id).tap do |n|
            attributes.each_with_index do |(key, value), index|
              n[key] = value
            end
          end
        end
        Deja.neo.execute_query(update_query)
      end

      def update_node_by_index(index_hash, attributes)
        update_query = Neo4j::Cypher.query do
          node(node_id).tap do |n|
            attributes.each_with_index do |(key, value), index|
              n[key] = value
            end
          end
        end
        Deja.neo.execute_query(update_query)
      end

      def delete_node(node_id)
        delete_query = Neo4j::Cypher.query() do
          node(node_id).del.both(rel().as(:r).del)
        end
        Deja.neo.execute_query(delete_query)
      end

      def create_relationship(start_node, end_node, name, attributes = {})
        create_query = Neo4j::Cypher.query() do
          relation = rel(name)
          create_path{
            node(start_node) > relation.as(:r).neo_id.ret > node(end_node)
          }
        end
        Deja.neo.execute_query(create_query)['data'].first.first
      end

      def update_relationship(rel_id, attributes)

      end

      def delete_relationship(rel_id)
        delete_query = Neo4j::Cypher.query() do
          rel(rel_id).del
        end
        begin
          Deja.neo.execute_query(delete_query)
        rescue
          raise Deja::Error::RelationshipDoesNotExist
        end
      end

      def create_node_with_relationship(relationship, attributes)

      end

      def load_entity(neo_id, relations = :all)
        return get_node_with_relationships(neo_id, relations) if relations.is_a? Array
        raise Deja::Error::InvalidParameter unless relations.is_a? Symbol
        return get_node_with_related_nodes(neo_id) if relations == :all
        return get_all_outgoing_nodes(neo_id)      if relations == :outgoing
        return get_all_incoming_nodes(neo_id)      if relations == :incoming
        return get_single_node(neo_id)             if relations == :none
        return get_node_with_relationship(neo_id, relations) if relations != :all
      end

      def get_single_node(neo_id)
        read_query = Neo4j::Cypher.query() do
          node(neo_id)
        end
        begin
          Deja.neo.execute_query(read_query)
        rescue
          raise Deja::Error::NodeDoesNotExist
        end
      end

      def get_single_relationship(rel_id)
        read_query = Neo4j::Cypher.query() do
          rel(rel_id)
        end
        begin
          Deja.neo.execute_query(read_query)
        rescue
          raise Deja::Error::RelationshipDoesNotExist
        end
      end

      def get_node_with_related_nodes(neo_id)
        read_query = Neo4j::Cypher.query() do
          relation = rel()
          node(neo_id).ret.both(relation.ret).ret
        end
        begin
          Deja.neo.execute_query(read_query)
        rescue
          raise Deja::Error::NodeDoesNotExist
        end
      end

      def get_related_nodes(neo_id)
        read_query = Neo4j::Cypher.query() do
          node(neo_id).both(rel.ret).ret
        end
        begin
          Deja.neo.execute_query(read_query)
        rescue
          raise Deja::Error::NodeDoesNotExist
        end
      end

      def get_node_with_outgoing_nodes(neo_id)
        read query = Neo4j::Cypher.query() do
          node(neo_id).ret >> node.ret
        end
        begin
          Deja.neo.execute_query(read_query)
        rescue
          raise Deja::Error::NodeDoesNotExist
        end
      end

      def get_outgoing_nodes(neo_id)
        read_query = Neo4j::Cypher.query() do
          node(neo_id) >> node.ret
        end
        begin
          Deja.neo.execute_query(read_query)
        rescue
          raise Deja::Error::NodeDoesNotExist
        end
      end

      def get_node_with_incoming_nodes(neo_id)
        read query = Neo4j::Cypher.query() do
          node(neo_id).ret << node.ret
        end
        begin
          Deja.neo.execute_query(read_query)
        rescue
          raise Deja::Error::NodeDoesNotExist
        end
      end

      def get_incoming_nodes(neo_id)
        read_query = Neo4j::Cypher.query() do
          node(neo_id) << node.ret
        end
        begin
          Deja.neo.execute_query(read_query)
        rescue
          raise Deja::Error::NodeDoesNotExist
        end
      end

      def get_node_with_relationship(neo_id, relationship)
        @neo.execute_cypher(neo_id) do |start_node|
          start_node(neo_id).ret - relationship.ret - node.ret
        end
      end

      def get_node_with_relationships(neo_id, relations = {})
        @neo.execute_cypher(neo_id) do |start_node|
          start_node(neo_id).ret - relations.join('|').ret - node.ret
        end
      end
    end
  end
end
