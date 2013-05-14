module Deja
  #
  # low-level cypher executions, most db access runs through bridge
  #
  module Bridge
    extend ActiveSupport::Concern

    module ClassMethods
      def get_or_create(*args)

      end

      def load_entity(neo_id)
        @neo.execute_cypher(neo_id) do |start_node|
          start_node
        end
      end

      def new(*args)

      end

      def unique_factory_key

      end
    end
  end
end