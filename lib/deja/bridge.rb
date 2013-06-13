module Deja
  #
  # low-level cypher executions, most db access runs through bridge
  #
  module Bridge
    extend ActiveSupport::Concern

    include Deja::NeoParse

    module ClassMethods

      def is_index?(node_lookup)
        node_lookup.is_a?(Hash)
      end

      def create_node(attributes = {})
        raise Deja::Error::InvalidParameter unless attributes
        raise Deja::Error::NoParameter if attributes.empty?
        query = Neo4j::Cypher.query() do
          node.new(attributes).neo_id
        end
        begin
          Deja.execute_cypher(query)['data'].first.first
        rescue Exception => e
          raise Deja::Error::CreationFailure, "#{e.message}"
        end
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
        begin
          Deja.execute_cypher(update_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def update_node_by_index(index_hash, attributes)
        update_query = Neo4j::Cypher.query do
          node(node_id).tap do |n|
            attributes.each_with_index do |(key, value), index|
              n[key] = value
            end
          end
        end
        begin
          Deja.execute_cypher(update_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def delete_node(node_id)
        delete_query = Neo4j::Cypher.query() do
          node(node_id).del.both(rel().as(:r).del)
        end
        begin
          Deja.execute_cypher(delete_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def create_relationship(start_node, end_node, name, attributes = {})
        create_query = Neo4j::Cypher.query() do
          relation = rel(name)
          create_path{
            node(start_node) > relation.as(:r).neo_id.ret > node(end_node)
          }
        end
        Deja.execute_cypher(create_query)['data'].first.first
      end

      def update_relationship(rel_id, attributes)

      end

      def delete_relationship(rel_id)
        delete_query = Neo4j::Cypher.query() do
          rel(rel_id).del
        end
        begin
          Deja.execute_cypher(delete_query)
        rescue Exception => e
          raise Deja::Error::RelationshipDoesNotExist, "#{e.message}"
        end
      end

      def create_node_with_relationship(relationship, attributes)

      end

      def load_entity_with_args(neo_id, relations = :all)
        return get_node_with_relationships(neo_id, relations) if relations.is_a? Array
        raise Deja::Error::InvalidParameter unless relations.is_a? Symbol
        return get_node_with_related_nodes(neo_id) if relations == :all
        return get_all_outgoing_nodes(neo_id)      if relations == :outgoing
        return get_all_incoming_nodes(neo_id)      if relations == :incoming
        return get_single_node(neo_id)             if relations == :none
        return get_node_with_relationship(neo_id, relations) if relations != :all
      end

      def load_entity(neo_id, relations = :all)
        entity = load_entity_with_args(neo_id, relations)
        normalize(entity)
      end

      def get_single_node(neo_id)
        read_query = Neo4j::Cypher.query() do
          node(neo_id)
        end
        begin
          Deja.execute_cypher(read_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def get_single_relationship(rel_id)
        read_query = Neo4j::Cypher.query() do
          rel(rel_id)
        end
        begin
          Deja.execute_cypher(read_query)
        rescue Exception => e
          raise Deja::Error::RelationshipDoesNotExist, "#{e.message}"
        end
      end

      def get_node_with_related_nodes(neo_id)
        read_query = Neo4j::Cypher.query() do
          relation = rel()
          node(neo_id).ret.both(relation.ret).ret
        end
        begin
          Deja.execute_cypher(read_query.to_s)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def get_related_nodes(neo_id)
        read_query = Neo4j::Cypher.query() do
          node(neo_id).both(rel.ret).ret
        end
        begin
          Deja.execute_cypher(read_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def get_node_with_outgoing_nodes(neo_id)
        read query = Neo4j::Cypher.query() do
          node(neo_id).ret >> node.ret
        end
        begin
          Deja.execute_cypher(read_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def get_outgoing_nodes(neo_id)
        read_query = Neo4j::Cypher.query() do
          node(neo_id) >> node.ret
        end
        begin
          Deja.execute_cypher(read_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def get_node_with_incoming_nodes(neo_id)
        read query = Neo4j::Cypher.query() do
          node(neo_id).ret << node.ret
        end
        begin
          Deja.execute_cypher(read_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def get_incoming_nodes(neo_id)
        read_query = Neo4j::Cypher.query() do
          node(neo_id) << node.ret
        end
        begin
          Deja.execute_cypher(read_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def get_node_with_relationship(neo_id, relationship)
        read_query = Neo4j::Cypher.query() do
          start_node(neo_id).ret - relationship.ret - node.ret
        end
        begin
          Deja.execute_cypher(read_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def get_node_with_relationships(neo_id, relations = {})
        read_query = Neo4j::Cypher.query() do
          start_node(neo_id).ret - relations.join('|').ret - node.ret
        end
        begin
          Deja.execute_cypher(read_query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end
    end
  end
end
