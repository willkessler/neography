module Deja
  #
  # low-level cypher executions, most db access runs through bridge
  #
  module Bridge
    extend ActiveSupport::Concern

    module ClassMethods
      def get_or_create(*args)

      end

      def load_entity(neo_id, *relations = :all)
        get_node_with_relationships(neo_id, relations) if relations.is_a? Array
        raise Deja::Error::InvalidParameter unless relations.is_a? Symbol
        get_all_related_nodes(neo_id) if relations == :all
        get_all_outgoing_nodes(neo_id) if relations == :outgoing
        get_all_incoming_nodes(neo_id) if relations == :incoming
        get_single_node(neo_id) if relations == :none
        get_node_with_relationship(neo_id)
      end

      def get_all_related_nodes(neo_id)
        @neo.execute_cypher(neo_id) do |start_node|
          start_node(neoid).ret <=> node.ret
        end
      end

      def get_all_outgoing_nodes(neo_id)
        @neo.execute_cypher(neo_id) do |start_node|
          start_node(neoid).ret >> node.ret
        end
      end

      def get_all_incoming_nodes(neo_id)
        @neo.execute_cypher(neo_id) do |start_node|
          start_node(neoid).ret << node.ret
        end
      end

      def get_single_node(neo_id)
        @neo.execute_cypher(neo_id) do |start_node|
          start_node
        end
      end

      def get_node_with_relationship(neo_id, relationship)
        @neo.execute_cypher(neo_id) do |start_node|
          start_node(neo_id).ret - relationship.ret - node.ret
        end
      end

      def get_node_with_relationships(neo_id, *relations)
        @neo.execute_cypher(neo_id) do |start_node|
          start_node(neo_id).ret - relations.join('|').ret - node.ret
        end
      end

      def new(*args)

      end

      def unique_factory_key

      end
    end
  end
end