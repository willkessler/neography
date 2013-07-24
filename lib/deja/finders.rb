module Deja
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      def load(id, index = false, options = {})
        options[:include] ||= :none
        entity_array = Deja::Query.load_node(id, options)
        objectify(entity_array)
      end

      def load_many(*ids)
        nodes = ids.map do |id|
          entity_array = Deja::Query.load_node(id)
          objectify(entity_array)
        end
        ids.length == 1 ? nodes.first : nodes
      end
    end
  end
end
