module Deja
  module Bridge
    extend ActiveSupport::Concern

    include Deja::NeoParse

    module ClassMethods
      def is_index?(node_lookup)
        node_lookup.is_a?(Hash)
      end

      def cypher(&block)
        Neo4j::Cypher.query(&block)
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
        query = cypher do
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
        query = cypher do
          node(node_id).tap do |n|
            attributes.each_with_index do |(key, value), index|
              n[key] = value
            end
          end
        end
        node_query(query)
      end

      def update_node_by_index(index_hash, attributes)
        query = cypher do
          node(node_id).tap do |n|
            attributes.each_with_index do |(key, value), index|
              n[key] = value
            end
          end
        end
        node_query(query)
      end

      def delete_node(node_id)
        query = cypher do
          node(node_id).del.both(rel().as(:r).del)
        end
        node_query(query)
      end

      def create_relationship(start_node, end_node, name, direction = :none, attributes = {})
        case direction
        when :none then
          query = cypher { create_path{ node(start_node) - rel(name).as(:r).neo_id.ret - node(end_node)} }
        when :out  then
          query = cypher { create_path{ node(start_node) > rel(name).as(:r).neo_id.ret > node(end_node)} }
        when :in   then
          query = cypher { create_path{ node(start_node) < rel(name).as(:r).neo_id.ret < node(end_node)} }
        else return false end
        node_query(query)['data'].first.first
      end

      def update_relationship(rel_id, attributes)

      end

      def delete_relationship(rel_id)
        query = cypher do
          rel(rel_id).del
        end
        rel_query(query)
      end

      def create_node_with_relationship(relationship, attributes)

      end

      def load_entity(neo_id, options={})
        entity = load_entity_with_args(neo_id, options)
        normalize(entity)
      end

      def load_entity_with_args(neo_id, options)
        options[:include] ||= :all
        get_node_with_rels(neo_id, options[:include])
      end

      def load_related_nodes(neo_id, options = {})
        entity = load_related_nodes_with_args(neo_id, options)
        # may need specialized normalize method to handle rels without start nodes
        normalize(entity)
      end

      def load_related_nodes_with_args(neo_id, options)
        options[:include] ||= :all
        get_related_nodes(neo_id, options[:include])
      end

      # includes origin node
      def get_node_with_rels(neo_id, rels)
        case rels
        when Array     then node_query cypher { node(neo_id).ret - rel(*rels).ret - node.ret }
        when :all      then node_query cypher { node(neo_id).ret.both(rel().ret).ret }
        when :outgoing then node_query cypher { node(neo_id).ret.outgoing(rel().ret).ret }
        when :incoming then node_query cypher { node(neo_id).ret.incoming(rel().ret).ret }
        when :none     then node_query cypher { node(neo_id) }
        else node_query cypher { node(neo_id).ret - rel(rels.to_sym).ret - node.ret } end
      end

      # does not include origin node
      def get_related_nodes(neo_id, rels)
        case rels
        when Array     then node_query cypher { node(neo_id) - rels.join('|').ret - node.ret }
        when :all      then node_query cypher { node(neo_id).both(rel().ret).ret }
        when :outgoing then node_query cypher { node(neo_id).outgoing(rel().ret).ret }
        when :incoming then node_query cypher { node(neo_id).incoming(rel().ret).ret }
        else node_query cypher { node(neo_id) - rel(rels.to_sym).ret - node.ret } end
      end

      def get_single_relationship(rel_id)
        query = cypher do
          rel(rel_id)
        end
        rel_query(query)
      end
    end
  end
end
