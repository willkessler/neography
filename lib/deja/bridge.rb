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

      def node_query(query)
        begin
          Deja.execute_cypher(query)
        rescue Exception => e
          raise Deja::Error::NodeDoesNotExist, "#{e.message}"
        end
      end

      def rel_query(query)
        begin
          Deja.execute_cypher(query)
        rescue Exception => e
          raise Deja::Error::RelationshipDoesNotExist, "#{e.message}"
        end
      end

      def create_node(attributes = {})
        raise Deja::Error::InvalidParameter unless attributes
        raise Deja::Error::NoParameter if attributes.empty?
        query = neo_query do
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
        query = Neo4j::Cypher.query do
          node(node_id).tap do |n|
            attributes.each_with_index do |(key, value), index|
              n[key] = value
            end
          end
        end
        node_query(query)
      end

      def update_node_by_index(index_hash, attributes)
        query = Neo4j::Cypher.query do
          node(node_id).tap do |n|
            attributes.each_with_index do |(key, value), index|
              n[key] = value
            end
          end
        end
        node_query(query)
      end

      def delete_node(node_id)
        query = neo_query do
          node(node_id).del.both(rel().as(:r).del)
        end
        node_query(query)
      end

      def create_relationship(start_node, end_node, name, attributes = {})
        query = neo_query do
          relation = rel(name)
          create_path{
            node(start_node) > relation.as(:r).neo_id.ret > node(end_node)
          }
        end
        node_query(query)['data'].first.first
      end

      def update_relationship(rel_id, attributes)

      end

      def delete_relationship(rel_id)
        query = neo_query do
          rel(rel_id).del
        end
        rel_query(query)
      end

      def create_node_with_relationship(relationship, attributes)

      end

      def load_entity_with_args(neo_id, options)
        options[:include] ||= :all
        get_node_with_rels(neo_id, options[:include])
      end

      def load_entity(neo_id, options={})
        entity = load_entity_with_args(neo_id, options)
        normalize(entity)
      end

      def neo_query(&block)
        Neo4j::Cypher.query(&block)
      end

      def get_node_with_rels(neo_id, rels)
        case rels
        when Array     then query = neo_query { node(neo_id).ret - rel(*rels).ret - node.ret }
        when :all      then query = neo_query { node(neo_id).ret.both(rel().ret).ret }
        when :outgoing then query = neo_query { node(neo_id).ret.outgoing(rel().ret).ret }
        when :incoming then query = neo_query { node(neo_id).ret.incoming(rel().ret).ret }
        when :none     then query = neo_query { node(neo_id) }
        else query = neo_query { node(neo_id).ret - rel(rels.to_sym).ret - node.ret }
        end
        node_query(query)
      end

      def get_single_relationship(rel_id)
        query = neo_query do
          rel(rel_id)
        end
        rel_query(query)
      end

      def get_related_nodes(neo_id, relationships = [])
        query = neo_query do
          if relationships.empty?
            node(neo_id).both(rel.ret).ret
          else
            node(neo_id) - relations.join('|').ret - node.ret
          end
        end
        node_query(query)
      end

      def get_outgoing_nodes(neo_id)
        query = neo_query do
          node(neo_id) >> node.ret
        end
        node_query(query)
      end

      def get_incoming_nodes(neo_id)
        query = neo_query do
          node(neo_id) << node.ret
        end
        node_query(query)
      end
    end
  end
end
