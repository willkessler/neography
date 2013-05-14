module Deja
  #
  # low-level cypher executions, most db access runs through bridge
  #
  module Bridge
    extend ActiveSupport::Concern

    module ClassMethods
      def get_or_create(*args)

      end

      def load_entity(neo_id, relations = :all)
        case relations
        when :all
          @neo.execute_cypher(neo_id) do |start_node|
            start_node(neoid).ret <=> node.ret
          end
          break
        when :outgoing
          @neo.execute_cypher(neo_id) do |start_node|
            start_node(neoid).ret >> node.ret
          end
          break
        when :incoming
          @neo.execute_cypher(neo_id) do |start_node|
            start_node(neoid).ret << node.ret
          end
          break
        when :none
          @neo.execute_cypher(neo_id) do |start_node|
            start_node
          end
          break
        # Assumes array of relationship types - should integrate type + directionality in future
        when Array
          @neo.execute_cypher(neo_id) do |start_node|
            start_node(neo_id).ret - relations.join('|').ret - node.ret
          end
          break
        else
          if(relations.is_a?(Symbol))
            @neo.execute_cypher(neo_id) do |start_node|
              start_node(neo_id).ret - relations.ret - node.ret
            end
          else
            raise Deja::Error::InvalidParameter
          end
        end
      end

      def new(*args)

      end

      def unique_factory_key

      end
    end
  end
end