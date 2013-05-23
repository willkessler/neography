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

      def create_node(attributes)
        new_node = @neo.execute_cypher() do
          node.new(attributes)
        end
      end

      def update_node(node_id, attributes)
        is_index?(node_id) ? update_node_by_index(node_id) : update_node_by_id(node_id)
      end

      def update_node_by_id(id)
        updated_node = @neo.execute_cypher() do
          node(node_id).tap do |n|
            attributes.each_with_index do |(key, value), index|
              n[key] = value
            end
          end
        end
      end

      def update_node_by_index(index_hash)
        updated_node = @neo.execute_cypher() do
          node(node_id).tap do |n|
            attributes.each_with_index do |(key, value), index|
              n[key] = value
            end
          end
        end
      end

      def delete_node(node_id)

      end

      def create_relationship(start_node, end_node, name, attributes)
        new_relationship = @neo.execute_cypher() do
          create_path{
            node(start_node.id) > rel(name) > node(end_node.id)
          }
        end
      end

      def update_relationship(rel_id, attributes)

      end


      def create_node_with_relationship(relationship, attributes)

      end

      def load_entity(neo_id, relations = :all)
        get_node_with_relationships(neo_id, relations) if relations.is_a? Array
        raise Deja::Error::InvalidParameter unless relations.is_a? Symbol
        get_all_related_nodes(neo_id) if relations == :all
        get_all_outgoing_nodes(neo_id) if relations == :outgoing
        get_all_incoming_nodes(neo_id) if relations == :incoming
        get_single_node(neo_id) if relations == :none
        get_node_with_relationship(neo_id, relations)
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
    end
  end
end
